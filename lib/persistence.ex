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



  @doc """
  Rebuild if events are found, if not found, return the container state with an empty data structure
  """
  def rebuild_from_events(%Container{} = state),  do: rebuild_from_events(state, 1)
  def rebuild_from_events(%Container{uuid: uuid, module: module, data: data} = state, start_version) do
    case Storage.read_stream_forward(uuid, start_version, @read_event_batch_size) do
      {:ok, batch} ->
        batch_size = length(batch)

        # TODO: rebuild the aggregate's state from the batch of events
        data = apply_events(module, data, clean_metadata(batch))
        # IO.inspect module.apply(data, Enum.at(batch,0))

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
      # every NEW data structure emits NoStream error (it try to find it)
      {:error, reason} ->
        state
    end
    state
  end

  @doc """
  Store events in eventstore
  """
  def persist_event([], _aggregate_uuid, _expected_version), do: :ok
  def persist_event(pending_events, uuid, expected_version) do
    :ok = Storage.append_to_stream(uuid, expected_version, pending_events)
  end

  @doc """
  Rebuild state data from saved snapshot
  """
  def rebuild_from_snapshot(%Container{uuid: uuid, module: module, data: data} = state) do
    #:ok =Storage

  end

  @doc """
  Persist state data
  """
  def persist_snapshot(%Container{uuid: uuid, module: module, data: data} = state) do
    :ok = Storage.fetch_state(uuid, data)

  end

  @doc """
  Receive a module that implements apply function, and rebuild the state from events
  """
  def apply_events(module, state, events), do:
    Enum.reduce(events, state, &module.apply(&2, &1))


  @doc """
  Clean metadata
  """
  def clean_metadata(events),           do: clean_metadata(events, [])
  def clean_metadata([], acc),          do: acc
  def clean_metadata([ {h,_} |t], acc), do: clean_metadata(t, acc ++ [h])

end

