defmodule Engine.Aggregate.Container do
  @moduledoc """
  The triangle: Aggregate Data Structure + Server's State (Container) + Side Effects
  This module encapsulates the Database side-efects over the aggregate's container. 
  The ideia is to have one point to reload the aggregate that lives inside the server's state,
  that I called here: container. So the logic needed to find it on snapshot and replay from the
  events that come afterwards are all encapsulated here. Theorically, it should be private functions
  inside the aggregate's server, but for easier testing, debuging, and maintaining, the rehydrate
  function will be the interface for this small sub-engine.
  Easier to test, debug and mantain :) . So we focus only on retrieving and persisting data here,
  creating new pids, and other decisions should be make by the server, repository and router.

  Note that when we snapshot, we save the server state, that contains the aggregate data structure,
  and we need to replay the remaining events only from the data structure. 
  The flow should be this: Load a snapshot, if found, replay events from there, 
    Load snapshot -> found    -> replay from there -> not found, return the snapshot
                                                      found, replay
                    not found -> try replay from scratch -> not found -> return a new data strcuture
                                                        found     -> replay
  It's optimistic, and try to find a solution. It's specially useful for process managers, that want
  to make snapshot for each state change (i.e. zero snapshot period), and automatically return the last
  one, even trying to read the following events.
  TODO: add ckecksum sync, to guarantee the counter state is the same as returned by the stream
  TODO: refactor and organize specs, rename bang functions
  """
  defstruct uuid: nil,            # uuid, obvious
            module: nil,          # the module name of the aggregate pure functional data structure 
            snapshot_period: nil, # every number of event, we snapshot
            aggregate: nil        # the data structure

  require Logger
  #require Engine.Aggregate.Aggregate.State
  alias Engine.Aggregate.Container
  alias Engine.Storage.Storage

  @typedoc "positions -> [first, last]"
  @type aggregate :: struct()           # the aggregate data structure
  @type container :: struct()           # the server that holds the aggregate data structure
  @type positions :: list(integer)      # positions from first and last saved events, i.e. {:ok, [3,5]}
  #@type module    :: atom()
  @type events    :: [struct()]
  @type uuid      :: String.t



  #@spec rehydrate(module, uuid)            :: aggregate
  @spec append_events(aggregate)           :: aggregate
  @spec append_snapshot(aggregate)         :: aggregate
  @spec append_events_snapshot(aggregate)  :: aggregate
  @spec load_events(container)             :: {:error, any()} | {:ok, events}
  #@spec load_snapshot(container)           :: {:error, any()} | {:ok, container}


  @doc """
  If we find a snapshot for this stream, we replay from that state position, 
  and if the snapshot is not find, we try to replay from scratch, and if not, 
  we give back the same empty container, once it's suposed to be a new one
  """
  def rehydrate(module, uuid) do
    load_snapshot(module, uuid)
      |> replay_from_snapshot(module)
  end


  @doc """
  Load the last snapshot for this container, and rebuild state based on module. If we can't load
  the snapshot for any reason, we return a new fresh datastructure, and in caller function, 
  events will be played from strach
  """
  def load_snapshot(module, uuid) do
    case Storage.load_snapshot(uuid) do
      {:ok, snapshot} ->
        agg = module.new(uuid) # struct State in runtime, but the module is a macro
        state = agg.state          # so we create a new datastructre to "template" it out
        new_state = struct_from_map(snapshot.state, as: state)  # our map has keys as strings
        %{snapshot | state: new_state}                   # so we need a custom converter
      {:error, reason} ->
        Logger.error "Loading snapshot failed for #{uuid} because #{reason}"
        module.new(uuid)
    end
  end


  @doc "rebuild an aggregate from a given snapshot, and replay events if found afterwards"
  def replay_from_snapshot(aggregate, module) do
    case Storage.load_events(aggregate.uuid, aggregate.counter) do
      {:ok, events}    -> module.load(aggregate, events) #aggregate |> module.load(events)
      {:error, reason} -> replay_from_events(module, aggregate.uuid)
    end
  end

  @doc "recostitute a containter from scratch"
  def replay_from_events(module, uuid, snapshot_period \\ 10) do
    aggregate = case Storage.load_all_events(uuid) do
      {:ok, events}    -> module.load(uuid, events)
      {:error, reason} -> module.new(uuid, snapshot_period)
    end
    # events list should only include uncommitted events
    %{aggregate | pending_events: []}
  end

  @doc """
  Main function API for writing, with auto-snapshot, that means, you append the events, and it
  will check inside the container, the event position and the snapshot period, and if it matches,
  it will automaticall generate a snapshot for this container. We first must append events and clean
  the pending events before snapshoting, so we will have a clean snapshot state written on the disk.
  TODO: sanity check, sync counter with last
  """
  def append_events_snapshot(aggregate) do
      aggregate
        |> append_events                      # append events and also CLEAN the pending ones !
        |> append_snapshot                    # now we pipe to snapshot
  end

  @doc "returns [first, last] positions of the appended events"
  def append_snapshot(aggregate) do
    case Storage.append_snapshot(aggregate.uuid, aggregate,
                                 aggregate.counter, aggregate.snapshot_period) do
      {:ok, [first, last]} -> aggregate       # TODO: sanity check, sync counter with last
      {:ok, :postponed}    -> aggregate
      {:error, reason}     ->
        Logger.error "Snapshoting aggregate failed for #{aggregate} because #{reason}"
        aggregate
    end
  end


  @doc "append events to the stream, reset pending events and update counter"
  def append_events(aggregate) do
    case Storage.append_events(aggregate.uuid, aggregate.pending_events) do
      {:ok, [first, last]} -> %{aggregate | pending_events: []}
      {:error, reason}     ->
        Logger.error "Appending events failed for #{aggregate} because #{reason}"
        aggregate
    end
  end


  @doc "load events from a spcecific position [extracts position from the aggregate inside]"
  def load_events(%Container{uuid: uuid, aggregate: aggregate} = server), do:
    Storage.load_events(uuid, aggregate.counter)


  @doc "create structs from maps when KEYs are strings...., oi vei"
  defp struct_from_map(a_map, as: a_struct) do
    # Find the keys within the map
    keys = Map.keys(a_struct)
             |> Enum.filter(fn x -> x != :__struct__ end)
    # Process map, checking for both string / atom keys
    processed_map =
     for key <- keys, into: %{} do
         value = Map.get(a_map, key) || Map.get(a_map, to_string(key))
         {key, value}
       end
    a_struct = Map.merge(a_struct, processed_map)
    a_struct
  end


end





  # @doc "if we succeed in appending events, we clean the data structure, if not, we send it back"
  # def append_events(%Container{uuid: uuid, aggregate: aggregate} = server) do
  #   case Storage.append_events(uuid, aggregate.pending_events) do
  #     {:ok, counter}   -> server = %{server | pending_events: []}
  #     {:error, reason} ->
  #       Logger.error "Error in appending data"
  #       aggregate
  #   end
  # end





  # defp load_events(%Aggregate{aggregate_module: aggregate_module, aggregate_uuid: aggregate_uuid} = state) do
  #   aggregate_state = case EventStore.read_stream_forward(aggregate_uuid) do
  #     {:ok, events} -> aggregate_module.load(aggregate_uuid, map_from_recorded_events(events))
  #     {:error, :stream_not_found} -> aggregate_module.new(aggregate_uuid)
  #   end
  #
  #   # events list should only include uncommitted events
  #   aggregate_state = %{aggregate_state | pending_events: []}
  #
  #   %Aggregate{state | aggregate_state: aggregate_state}
  # end
  #
  # def handle_cast({:fetch_state}, %ProcessManagerInstance{process_uuid: process_uuid, process_manager_module: process_manager_module} = state) do
  #   state = case EventStore.read_snapshot(process_state_uuid(state)) do
  #     {:ok, snapshot} -> %ProcessManagerInstance{state | process_state: process_manager_module.new(process_uuid, snapshot.data)}
  #     {:error, :snapshot_not_found} -> state
  #   end
  #
  #   {:noreply, state}
  # end
  #
  # defp persist_events(%{pending_events: []} = aggregate_state, _expected_version), do: {:ok, aggregate_state}
  #
  # defp persist_events(%{uuid: aggregate_uuid, pending_events: pending_events} = aggregate_state, expected_version) do
  #   correlation_id = UUID.uuid4
  #   event_data = Mapper.map_to_event_data(pending_events, correlation_id)
  #
  #   :ok = EventStore.append_to_stream(aggregate_uuid, expected_version, event_data)
  #
  #   # clear pending events after appending to stream
  #   {:ok, %{aggregate_state | pending_events: []}}
  # end
  #
  # defp persist_state(%ProcessManagerInstance{process_manager_module: process_manager_module, process_state: process_state} = state) do
  #   :ok = EventStore.record_snapshot(%EventStore.Snapshots.SnapshotData{
  #     source_uuid: process_state_uuid(state),
  #     source_version: 1,
  #     source_type: Atom.to_string(Module.concat(process_manager_module, Container)),
  #     data: process_state.state
  #   })
  # end
  #
  # def get_by_id(id, aggregate, supervisor) do
  #   case :syn.find_by_key(id) do
  #     :undefined ->
  #       load_from_eventstore(id, aggregate, supervisor)
  #     pid ->
  #       IO.inspect "found on cache"
  #       {:ok, pid}
  #   end
  # end
  #
  # # send the 'save' function to aggregate, so save will be done there after receiving
  # # a "process_unsaved_changes" message. Also clean event buffer
  # def save(pid, aggregate) do
  #   saver = fn(id, state, events) ->          # build SAVER anonymous function
  #     {:ok, event_counter} = EventStore.append_events(id, events)
  #     state = %{state | changes: []}          # clen state [fix the __struct__ bug when decode JSON
  #     EventStore.append_snapshot(id, state)   # snapshot state after cleaning event buffer
  #     event_counter + 1                       # returns the counter so it will be stored on state there
  #   end
  #   aggregate.process_unsaved_changes(pid, saver)
  # end
  #
  # #######################
  # # INTERNAL FUNCTIONS  #
  # #######################
  #
  # # without snapshot, we replay from the begining, else, from the snapshot
  # defp load_from_eventstore(id, aggregate, supervisor) do
  #   snapshot = EventStore.load_snapshot(id)
  #   case snapshot do
  #     {:error, _} ->
  #       replay_from_begining(id, aggregate, supervisor)
  #     {:ok, snapshot} ->
  #       replay_from_snapshot(id, aggregate, supervisor, snapshot)
  #   end
  # end
  #
  # defp replay_from_begining(id, aggregate, supervisor) do
  #   case EventStore.load_events(id) do
  #     {:error, _} ->
  #       :not_found
  #     {:ok, events} ->
  #       {:ok, pid} = supervisor.new
  #       aggregate.load_from_history(pid, events)
  #       {:ok, pid}
  #   end
  # end
  #
  # defp replay_from_snapshot(id, aggregate, supervisor, snapshot) do
  #   IO.inspect "replaying from snapshot"
  #   position = snapshot.event_counter + 1   # ajust to next event from that snapshot
  #   case EventStore.load_events(id, position) do
  #     {:error, _} ->
  #       :not_found
  #     {:ok, events} ->
  #       {:ok, pid} = supervisor.new
  #       aggregate.load_from_snapshot(pid, events, snapshot)
  #       {:ok, pid}
  #   end
  # end



