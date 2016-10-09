defmodule Engine.Messages do

  @moduledoc """
  Eventstore database use PROTOBUF, that is a compressed binary protocol. So all our communication
  with Eventstore is through messaging. Here we create this messages to send afterwards them to 
  Hey, only! the store.ex is using this API. This is the most 'low level' communication with the ES
  Eventstore. Example:
  events  =  [%PersonCreated{name: "Pera Peric"}, %PersonChangedName{name: "Zika"}]
  Common.Factory.write_events("people", events)
  Note that it will first create_event for every event in the list of events.
  """

  #@spec write_events(String, [Struct]) :: 
  @doc "create a write message for a list of events"
  def write_events(stream, events) do
    proto_events = Enum.map(events, &create_event/1) # map the list of structs to event messages
    Extreme.Messages.WriteEvents.new(
      event_stream_id: stream,
      expected_version: -2,
      events: proto_events,
      require_master: false
    )
  end

  @doc "create one event message based on a struct"
  defp create_event(event) do
    Extreme.Messages.NewEvent.new(
      event_id: Extreme.Tools.gen_uuid(),
      event_type: to_string(event.__struct__),
      data_content_type: 0,
      metadata_content_type: 0,
      data: Engine.Serializer.encode(event),
      meta: ""
    )
  end

  @doc "create a message to read all events for a stream"
  def read_events(stream) do
    Extreme.Messages.ReadStreamEvents.new(
      event_stream_id: stream,
      from_event_number: 0,
      max_count: 4096,
      resolve_link_tos: true,
      require_master: false
    )
  end

  @doc "create a message to read the last event/snapshot only."
  def read_event_backward(stream) do
    Extreme.Messages.ReadStreamEventsBackward.new(
      event_stream_id: stream,
      from_event_number: -1,
      max_count: 1,
      resolve_link_tos: true,
      require_master: false
    )
  end

  @doc "create a message to read events from a specific position"
  def read_events(stream, position) do
    Extreme.Messages.ReadStreamEvents.new(
      event_stream_id: stream,
      from_event_number: position,
      max_count: 4096,
      resolve_link_tos: true,
      require_master: false
    )
  end

  @doc "delete a stream"
  def delete_stream(stream, hard_delete \\ false) do
    Extreme.Messages.DeleteStream.new(
      event_stream_id: stream,
      expected_version: -2,
      require_master: false,
      hard_delete: hard_delete
    )
  end
end
