# Original Work: Copyright (c) 2016 Ben Smith (ben@10consulting.com)
defprotocol Engine.Storage.Postgres.JsonDecoder do
  @doc """
  Protocol to allow additional decoding of a value that has been deserialized using the `Commanded.Serialization.JsonSerializer`.
  The protocol is optional. The default behaviour is to to return the value if an explicit protocol is not defined.
  """
  @fallback_to_any true
  def decode(data)
end

defimpl Engine.Storage.Postgres.JsonDecoder, for: Any do
  @moduledoc """
  Null decoder for values that require no additional decoding.
  
  Returns the data exactly as provided.
  """
  def decode(data), do: data
end
