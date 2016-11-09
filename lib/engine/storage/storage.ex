defmodule Engine.Storage.Storage do
  require Logger
  @storage Engine.Settings.get(:storage)   # can be Eventstore or Postgres
  @moduledoc """
  Proxy API layer to provide a Facade for different data storages. 
  The ideia is to read from the config file
  what is the choosen storage, and route the call to the specifc implementation.
  http://elixir-lang.org/docs/stable/elixir/typespecs
  """
  @type position :: integer
  @type result   :: {position, String.t}
  @type stream   :: String.t
  @type event    :: struct()
  @type events   :: [struct()]

  # TODO: fill specs and check 'mix dialyzer'
  @spec which_storage?() :: atom
  @spec append_event(stream, event)   :: any()
  @spec append_events(stream, events) :: any()


  @doc "If you want to know what storage is configured"
  def which_storage?(), do: @storage

  @doc "Save only one event to the stream."
  def append_event(stream, event), do:
    @storage.append_event(stream, event)

  @doc "Save a list of events to the stream."
  def append_events(stream, events), do:
    @storage.append_events(stream, events)

  @doc "Load all events for that stream"
  def load_all_events(stream), do:
    @storage.load_all_events(stream)

  @doc "Load events, but from a specific position"
  def load_events(stream, position), do:
    @storage.load_events(stream, position)

  @doc "Save snapshot after checking the frequency config, adding -snapshot to its namespace"
  def append_snapshot(stream, state, period \\ @snapshot_period), do:
    @storage.append_snapshot(stream, state, period)

  @doc "Load the last snapshot for that stream"
  def load_snapshot(stream), do:
    @storage.load_snapshot(stream)

end

