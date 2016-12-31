defmodule Workflow.Serialization do
  @protocol Json     # -> choose here your protocol TODO: move it to config

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
