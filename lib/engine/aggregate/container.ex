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

  This name: contanier is also a way to fix the trauma, if you come from Enterprise Java Beans,
  you will love it, specially that it can take some miliseconds to start some millions
  of them ;)

  Note that when we snapshot, we save the server state, that contains the aggregate data structure,
  and we need to replay the remaining events only from the data structure. 
  """

  defstruct uuid: nil,     # the module name of the aggregate pure functional data structure
            module: nil,       # uuid
            aggregate: nil   # the data structure

  require Logger
  alias Engine.Aggregate.Container
  alias Engine.Storage.Storage

  @typedoc "positions -> [first, last]"
  @type aggregate :: struct()           # the aggregate data structure
  @type container :: struct()           # the server that holds the aggregate data structure
  @type positions :: list(integer)      # first postion of the first event, and last from the last
  @type events    :: [struct()]
  @type uuid      :: String.t


  @spec append_snapshot(container)  :: {:error, any()} | {:ok, positions}
  @spec load_events(container)      :: {:error, any()} | {:ok, events}
  @spec load_snapshot(container)    :: {:error, any()} | {:ok, container}


  @doc """
  Search for snapshot and replay from that state position, if we find the snapshot, we try to replay
  events from the event counter position, and if not, we try to replay from scratch, and if not, 
  we give back the same empty container, once it's suposed to be a new one
  """
  def rehydrate(%Container{uuid: uuid, module: module, aggregate: aggregate} = container) do
    case load_snapshot(container) do
      {:ok, loaded_container} -> load_events(loaded_container)
      {:error, reason}        -> load_events(container)
    end
  end

  @doc "load events from a specific position"
  def load_events(%Container{uuid: uuid, aggregate: aggregate} = server) do
    position = aggregate.counter
    Storage.load_events(uuid, position)
  end

  @doc "load events from scratch"
  def load_all_events(%Container{uuid: uuid} = server), do:
    Storage.load_all_events(uuid)

  @doc "returns [first, last] positions of the appended events"
  def append_events(%Container{uuid: uuid, aggregate: aggregate}), do:
    Storage.append_events(uuid, aggregate.pending_events)

  @doc "returns [first, last] positions of the appended events"
  def append_snapshot(%Container{uuid: uuid} = server), do:
    Storage.append_snapshot(uuid, server)

  @doc "load the last snapshot for this container"
  def load_snapshot(%Container{uuid: uuid}), do:
    Storage.load_snapshot(uuid)


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



end
