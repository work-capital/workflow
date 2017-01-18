defmodule Workflow.Adapter do
  @moduledoc """
  Implement this functions below to add a new data storage for your events and snapshots.
  The persistence modules will retreive a pure list of events, ready for replay, instead of
  dealing with localized messages. It's an adapter responsability to filter and answer only the
  necessary data to be used inside Commanded
  """

  @type stream_id              :: String.t
  @type start_version          :: number
  @type read_event_batch_size  :: number
  @type batch                  :: [struct()]
  @type stream                 :: String.t     # The Stream ID
  @type reason                 :: atom
  @type expected_version       :: number
  @type data                   :: struct()
  @type metadata               :: struct()
  @type state                  :: struct()
  @type version                :: number




  @doc "Load a list of events from an specific position"
  @callback append_to_stream(stream_id, expected_version, data, metadata) ::
    :ok | {:error, reason}

  @doc "Load a batch of events from storage"
  @callback read_stream_forward(stream_id, start_version, read_event_batch_size) ::
    {:ok, batch} | {:error, reason}

  @doc "Fetch a state snapshot"
  @callback read_stream_backward(stream_id, state)  :: :ok  | {:error, reason}

end
