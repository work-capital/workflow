defmodule Workflow.Persistence do
  @read_event_batch_size 100
  @moduledoc """
  Database side effects from Aggregates and Process Managers servers. Having them in a segregated
  file helps to test, debug and share the uncommon code between them
  """

  alias Workflow.Container
  alias Workflow.Storage
  require Logger




  @typedoc "positions -> [first, last]"
  @type state     :: struct()           # the aggregate or process manager data structure
  @type events    :: [struct()]
  @type uuid      :: String.t
  @type reason    :: atom
  @type stream    :: String.t


  #@spec fetch_state(module, stream)    ::   {:ok, state}  |  {:error, reason}


  @doc "Rebuild from events"
  def rebuild_from_events(%Container{} = state),  do: rebuild_from_events(state, 1)
  def rebuild_from_events(%Container{uuid: uuid, module: module, data: data} = state, start_version) do
    case Storage.read_stream_forward(uuid, start_version, @read_event_batch_size) do
      {:ok, batch} ->
        batch_size = length(batch)

        # rebuild the aggregate's state from the batch of events
        data = apply_events(module, data, batch)

        state = %Container{state |
          version: start_version - 1 + batch_size,
          data: data
        }

        case batch_size < @read_event_batch_size do
          true ->
            # end of event stream for aggregate so return its state
            state

          false ->
            # fetch next batch of events to apply to updated aggregate state
            rebuild_from_events(state, start_version + @read_event_batch_size)
        end

      {:error, :stream_not_found} ->
        # aggregate does not exist so return empty state
        state
    end
  end

  def persist_events([], _aggregate_uuid, _expected_version), do: :ok
  def persist_events(pending_events, uuid, expected_version) do
    :ok = Storage.append_to_stream(uuid, expected_version, pending_events)
  end


  @doc "Receive a module that implements apply function, and rebuild the state from events"
  def apply_events(module, state, events), do:
    Enum.reduce(events, state, &module.apply(&2, &1))

end

