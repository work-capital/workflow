defmodule Workflow.Storage do
  require Logger
  @moduledoc """
  Proxy API layer to provide a Facade for different data storages, with optimization logic,
  like snapshots, batch reading, etc... 
  The ideia is to read from the config file
  what is the choosen storage, and route the call to the specifc implementation.
  http://elixir-lang.org/docs/stable/elixir/typespecs
  """
  # defaults
  @default_adapter Workflow.Adapter.Extreme
  @read_event_batch_size 100

  # types
  @type position :: integer
  @type result   :: {position, String.t}
  @type stream   :: String.t
  @type event    :: struct()
  @type events   :: [struct()]


  @doc "Recieve internal event data to append. message building is an adapter task."
  def append_to_stream(stream_id, expected_version, data, metadata), do:
    adapter.append_to_stream(stream_id, expected_version, data, metadata)

  @doc "Read pure events from stream"
  def read_stream_forward(stream_id, start_version, read_event_batch_size \\ @read_event_batch_size), do:
    adapter.read_stream_forward(stream_id, start_version, read_event_batch_size)

  @doc "Persist process manager state"
  def persist_state(stream_id, version, type, data), do:
    adapter.persist_state(stream_id, version, type, data)

  @doc "Fech state, if not found, returns the same"
  def fetch_state(stream_id, state), do:
    adapter.fetch_state(stream_id, state)

  @doc "Get choosen db adapter from config files"
  defp adapter(), do:
    Application.get_env(:workflow, :adapter, @default_adapter)


end

