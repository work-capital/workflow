defmodule Workflow.Mapper do
  @moduledoc """
  Map raw events to event data structs ready to be persisted to the event store.
  """
  alias Extreme.Messages.ReadStreamEvents
  alias Extreme.Messages.WriteEvents
  alias Extreme.Messages.NewEvent

  alias Workflow.Serialization


  def extract_events({:ok, response}),   do: {:ok, Enum.map(response.events, &extract_data/1)}
  def extract_events({:error,_}),        do: {:error, :not_found}
  def extract_events({:error,_,_}),      do: {:error, :not_found}

  # rebuild the struct from a string stored in the eventstore
  @doc "extract data from result messages"
  def extract_data(message) do
    st = message.event.event_type 
         |> convert_string_to_atom 
         |> struct

    message.event.data 
         |> deserialize(st)
  end

  # transforms a ":Jim" string into a Jim atom alias
  defp convert_string_to_atom(name) do
    name_s = String.to_atom(name)
    ast = {:__aliases__, [alias: false], [name_s]}
    {result, _} = Code.eval_quoted(ast)
    result
  end

  defp deserialize(data, struct \\ nil),
    do: Serialization.decode(data, struct)

  @doc "create a read stream message"
  def map_read_stream(stream_id, from_event_number, max_count) do
    %ReadStreamEvents{
      event_stream_id: stream_id,
      from_event_number: from_event_number,
      max_count: max_count,
      resolve_link_tos: true,
      require_master: false
    }
  end


  @doc "create a write message for a list of events"
  def map_write_events(stream_id, events) do
    proto_events = Enum.map(events, &create_event/1) # map the list of structs to event messages
    WriteEvents.new(
      event_stream_id: stream_id,
      expected_version: -2,
      events: proto_events,
      require_master: false
    )
  end
  defp create_event(event) do
    NewEvent.new(
      event_id: Extreme.Tools.gen_uuid(),
      event_type: to_string(event.__struct__),
      data_content_type: 0,
      metadata_content_type: 0,
      data: Serialization.encode(event),
      meta: ""
    )
  end

end
