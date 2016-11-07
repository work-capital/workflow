defmodule Engine.Serializer do
  @moduledoc """
  It's possible that you want to serialize all your messages to json before sending to the EventStore,
  or you can choose to save as a binary, or hybrid, like, your event data in binary and the whole
  Eventstore message in json. To define your event data, go to Engine.Messages, and to serialize the 
  whole message see the Engine.EventStore

    @enconder  Json | Binary

    TODO: fix decode as %Person{} bug, see test result below, and check doc:
    https://github.com/devinus/poison

     code: res == %MyState{state: "good shape", event_counter: 24}
     lhs:  %{"changes" => nil, "event_counter" => 24, "state" => "good shape"}
     rhs:  %EventStoreTest.MyState{changes: nil, event_counter: 24,
            state: "good shape"}
  """

  @protocol Json     # -> choose here your protocol

  def encode(data),
    do: internal_encode(@protocol, data)
  def decode(data, struct \\ nil),         # to decode with Poison, we need the Struct
    do: internal_decode(@protocol, data, struct)


  # JSON
  defp internal_encode(Json, data),
    do: Poison.encode!(data)
  defp internal_decode(Json, data, struct),
    do: Poison.decode!(data, as: struct)

  # BINARY
  defp internal_encode(Binary, data),
    do: :erlang.term_to_binary(data)
  defp internal_decode(Binary, data, struct),
    do: :erlang.binary_to_term(data)
end
