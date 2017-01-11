defmodule Workflow.Extreme.Mapper do
  @moduledoc """
  Map raw events to event data structs ready to be persisted to the event store.
  """
  # serialization alias
  alias Workflow.Extreme.Serialization

  # extreme aliases
  alias Extreme.Messages.ReadStreamEvents
  alias Extreme.Messages.WriteEvents
  alias Extreme.Messages.NewEvent


  def extract_events({:ok, response}),   do: {:ok, Enum.map(response.events, &extract_data/1)}
  def extract_events({:error,_}),        do: {:error, :not_found}
  def extract_events({:error,_,_}),      do: {:error, :not_found}

  # rebuild the struct from a string stored in the eventstore
  def extract_data(message) do
    st = message.event.event_type |> make_alias |> struct
    data = message.event.data |> deserialize(st)
    meta = message.event.metadata |> decode
    {data, meta}
  end

  # transforms a ":Jim" string into a Jim atom alias
  def make_alias(name) do
    name_s = String.to_atom(name)
    ast = {:__aliases__, [alias: false], [name_s]}
    {result, _} = Code.eval_quoted(ast)
    result
  end

  defp deserialize(data, struct \\ nil),
    do: Serialization.decode(data, struct)

  defp decode(map),
    do: Poison.decode!(map)

  @doc "create a write message to write events, state, or anything else"
  def map_write(stream, data, metadata) do
    WriteEvents.new(
      event_stream_id: stream,
      expected_version: -2,
      events: [NewEvent.new(
        event_id: Extreme.Tools.gen_uuid(),
        event_type: to_string(data.__struct__),
        data_content_type: 0,
        metadata_content_type: 0,
        data: Serialization.encode(data),
        metadata: Poison.encode!(metadata)
      )],
      require_master: false
    )
  end

  @doc "create a read stream message"
  def map_read_forwards(stream_id, from_event_number, max_count) do
    %ReadStreamEvents{
      event_stream_id: stream_id,
      from_event_number: from_event_number,
      max_count: max_count,
      resolve_link_tos: true,
      require_master: false
    }
  end

  @doc "to read snapshots, we get the last saved state"
  def map_read_backwards(stream_id) do
    Extreme.Messages.ReadStreamEventsBackward.new(
      event_stream_id: stream_id,
      from_event_number: -1,
      max_count: 1,
      resolve_link_tos: true,
      require_master: false
    )
  end

end
