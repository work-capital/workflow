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

  # aggregate = Atom name of the Aggregate module
  # pid | undefined
  def get_by_id(id, aggregate, supervisor) do
    case :syn.find_by_key(id) do
      :undefined ->
        load_from_eventstore(id, aggregate, supervisor)
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

