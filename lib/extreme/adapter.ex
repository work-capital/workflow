defmodule Workflow.Extreme.Adatper do
  require Logger
  @moduledoc """ 
  Interface with the Extreme EventStore driver to save and read to EVENTSTORE.
  Note that the Engine supervisor starts the driver naming it as 'EventStore'.
  """
  alias Workflow.Extreme.Mapper
  alias Extreme.Messages.WriteEventsCompleted

  @behaviour Workflow.Adapter
  @extreme Workflow.Extreme  # the pid name we called it on 

  @type aggregate_uuid        :: String.t
  @type start_version         :: String.t
  @type batch_size            :: integer()
  @type batch                 :: list()
  @type reason                :: atom()
  @type read_event_batch_size :: integer()



  @doc "Save a list of events to the stream."
  def append_to_stream(stream_id, expected_version,  pending_events) do
    # attention, erlangish pattern matching (^)
    message = Mapper.map_write_events(stream_id, pending_events)
    version = expected_version + 1 # postgre driver counts + 1, so let's fix adding 1 here
    {:ok, %WriteEventsCompleted{first_event_number: ^version}} =
      Extreme.execute(@extreme, message)
    :ok
  end


  @doc "Read stream, transforming messages in an event list ready for replay"
  def read_stream_forward(stream_id, start_version, read_event_batch_size) do
    message = Mapper.map_read_stream(stream_id, start_version, read_event_batch_size)
    case Extreme.execute(@extreme, message) do
      {:ok, events} -> Mapper.extract_events({:ok, events})
      {:error, reason} -> {:error, reason}
    end
  end

end
