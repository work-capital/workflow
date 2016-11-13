defmodule Engine.Storage.Postgres do
  require Logger

  @moduledoc """ 
  Interface with the Postgre eventstore lib,  driver to save and read to POSTGRE.
  """

  @doc "Save only one event to the stream."
  def append_event(stream, event) do
  end

  @doc "Save a list of events to the stream."
  def append_events(stream, events) do
  end

  @doc "Load all events for that stream"
  def load_events(stream) do
  end

  @doc "Load events, but from a specific position"
  def load_events(stream, position) do
  end


  @doc "Save snapshot after checking the frequency config, adding -snapshot to its namespace"
  def append_snapshot(stream, state, period \\ @snapshot_period) do
  end


  @doc "Load the last snapshot for that stream"
  def load_snapshot(stream) do
  end

  ###############
  ## PRIVATES  ##
  ###############

  # defp deserialize(data, struct \\ nil),
  #   do: Engine.Storage.Serializer.decode(data, struct)
  #   #do: :erlang.binary_to_term(data)
  #   # do: Poison.decode!(data)
  #
  # # partially applying Extreme.execute, so you can use this func with pipe operators
  # defp send_to_eventstore(message),
  #   do: Extreme.execute(@event_store, message)
  #
  # # transforms a ":Jim" string into a Jim atom alias
  # def make_alias(name) do
  #   name_s = String.to_atom(name)
  #   ast = {:__aliases__, [alias: false], [name_s]}
  #   {result, _} = Code.eval_quoted(ast)
  #   result
  # end


  @doc "C = counter, P = position, it returns true if the counter beats the position"
  defp mod(0,p),             do: true    # we snapshot the state from the first event
  defp mod(c,p) when c  < p, do: false
  defp mod(c,p) when c >= p  do
    case rem c,p do
      0 -> true
      _ -> false
    end
  end

end
