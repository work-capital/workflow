defmodule Workflow.Adapter do
  @moduledoc """
  Implement this functions below to add a new data storage for your events and snapshots.
  The persistence modules will retreive a pure list of events, ready for replay, instead of
  dealing with localized messages. It's an adapter responsability to filter and answer only the
  necessary data to be used inside Commanded
  """

  @type stream            :: String.t     # The Stream ID
  @type position          :: integer      # From which position we start reading the stream
  @type events            :: [struct()]   # TODO: implement common data strucutre 
  @type event_data        :: [struct()]
  @type expected_version  :: number
  @type stream_id         :: String.t
  @type batch             :: [struct()]
  @type state             :: struct()
  @type reason            :: atom
  @type snapshot          :: struct()
  @type start_pos         :: position     # When appending many events, the start position we got
  @type end_pos           :: position     # When appending many events, the last position we got
  @type read_event_batch_size  :: number
  @type start_version          :: number
  @type type              :: atom
  @type version           :: number



  @doc "Load a batch of events from storage"
  @callback read_stream_forward(stream_id, start_version, read_event_batch_size) ::
    {:ok, batch} | {:error, reason}

  @doc "Load a list of events from an specific position"
  @callback append_to_stream(stream_id, expected_version, event_data) ::
    :ok | {:error, reason}



end
