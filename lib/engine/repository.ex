defmodule Engine.Repository do
  @moduledoc """
  This module is the Repository for Aggregates, Process Managers, or anything else that has a PID
  and you want to store and load the state from cache, from some snapshot, replay events from that
  snapshot or even from the begining. For several reasons we choosed SYN to store pids. Note that
  the BPE https://github.com/spawnproc/bpe also choosed SYN. 
  http://www.ostinelli.net/an-evaluation-of-erlang-global-process-registries-meet-syn/
  https://github.com/ostinelli/syn
  """

  alias Engine.EventStore

  def add_to_cache(id, pid), do:
    :syn.register(id, pid, :undefined)

  # ok | {error, Error}, Error = taken | pid_already_registered 
  def remove_from_cache(id), do:
    :syn.unregister(id)



  def open_aggregate(aggregate_module, aggregate_uuid)
  when is_integer(aggregate_uuid) or
       is_atom(aggregate_uuid) or
       is_bitstring(aggregate_uuid) do
    GenServer.call(__MODULE__, {:open_aggregate, aggregate_module, to_string(aggregate_uuid)})
  end

    # aggregate = case Map.get(aggregates, aggregate_uuid) do
    #   nil -> start_aggregate(supervisor, aggregate_module, aggregate_uuid)
    #   aggregate -> aggregate
    # {:ok, aggregate} = Aggregates.Supervisor.start_aggregate(supervisor, aggregate_module, aggregate_uuid)
    # Process.monitor(aggregate)
    # aggregate

  # aggregate = Atom name of the Aggregate module
  # pid | undefined
  def open_aggregate(uuid, module) do
    case :syn.find_by_key(uuid) do
      :undefined ->
        :ok #load_from_eventstore(uuid, aggregate, supervisor)
      pid ->
        IO.inspect "found on cache"
        {:ok, pid}
    end
  end

  # send the 'save' function to aggregate, so save will be done there after receiving
  # a "process_unsaved_changes" message. Also clean event buffer
  def save(pid, aggregate) do
    saver = fn(id, state, events) ->          # build SAVER anonymous function
      {:ok, event_counter} = EventStore.append_events(id, events)
      state = %{state | changes: []}          # clen state [fix the __struct__ bug when decode JSON
      EventStore.append_snapshot(id, state)   # snapshot state after cleaning event buffer
      event_counter + 1                       # returns the counter so it will be stored on state there
    end
    aggregate.process_unsaved_changes(pid, saver)
  end

  #######################
  # INTERNAL FUNCTIONS  #
  #######################

  # without snapshot, we replay from the begining, else, from the snapshot
  defp load_from_eventstore(id, aggregate, supervisor) do
    snapshot = EventStore.load_snapshot(id)
    case snapshot do
      {:error, _} ->
        replay_from_begining(id, aggregate, supervisor)
      {:ok, snapshot} ->
        replay_from_snapshot(id, aggregate, supervisor, snapshot)
    end
  end

  defp replay_from_begining(id, aggregate, supervisor) do
    case EventStore.load_events(id) do
      {:error, _} ->
        :not_found
      {:ok, events} ->
        {:ok, pid} = supervisor.new
        aggregate.load_from_history(pid, events)
        {:ok, pid}
    end
  end

  defp replay_from_snapshot(id, aggregate, supervisor, snapshot) do
    IO.inspect "replaying from snapshot"
    position = snapshot.event_counter + 1   # ajust to next event from that snapshot
    case EventStore.load_events(id, position) do
      {:error, _} ->
        :not_found
      {:ok, events} ->
        {:ok, pid} = supervisor.new
        aggregate.load_from_snapshot(pid, events, snapshot)
        {:ok, pid}
    end
  end

end
#
# defmodule Commanded.Aggregates.Registry do
#   @moduledoc """
#   Provides access to an event sourced aggregate by id
#   """
#
#   use GenServer
#   require Logger
#
#   alias Commanded.Aggregates
#   alias Commanded.Aggregates.Registry
#
#   defstruct aggregates: %{}, supervisor: nil
#
#   def start_link do
#     GenServer.start_link(__MODULE__, %Registry{}, name: __MODULE__)
#   end
#
#   def open_aggregate(aggregate_module, aggregate_uuid)
#   when is_integer(aggregate_uuid) or
#        is_atom(aggregate_uuid) or
#        is_bitstring(aggregate_uuid) do
#     GenServer.call(__MODULE__, {:open_aggregate, aggregate_module, to_string(aggregate_uuid)})
#   end
#
#   def init(%Registry{} = state) do
#     {:ok, supervisor} = Aggregates.Supervisor.start_link
#
#     state = %Registry{state | supervisor: supervisor}
#
#     {:ok, state}
#   end
#
#   def handle_call({:open_aggregate, aggregate_module, aggregate_uuid}, _from, %Registry{aggregates: aggregates, supervisor: supervisor} = state) do
#     aggregate = case Map.get(aggregates, aggregate_uuid) do
#       nil -> start_aggregate(supervisor, aggregate_module, aggregate_uuid)
#       aggregate -> aggregate
#     end
#
#     {:reply, {:ok, aggregate}, %Registry{state | aggregates: Map.put(aggregates, aggregate_uuid, aggregate)}}
#   end
#
#   def handle_info({:DOWN, _ref, :process, pid, reason}, %Registry{aggregates: aggregates} = state) do
#     Logger.warn(fn -> "aggregate process down due to: #{inspect reason}" end)
#
#     {:noreply, %Registry{state | aggregates: remove_aggregate(aggregates, pid)}}
#   end
#
#   defp start_aggregate(supervisor, aggregate_module, aggregate_uuid) do
#     {:ok, aggregate} = Aggregates.Supervisor.start_aggregate(supervisor, aggregate_module, aggregate_uuid)
#     Process.monitor(aggregate)
#     aggregate
#   end
#
#   defp remove_aggregate(aggregates, pid) do
#     Enum.reduce(aggregates, aggregates, fn
#       ({aggregate_uuid, aggregate_pid}, acc) when aggregate_pid == pid -> Map.delete(acc, aggregate_uuid)
#       (_, acc) -> acc
#     end)
#   end
# end
