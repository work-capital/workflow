defmodule Engine.Storage.Storage do
  require Logger
  @storage Engine.Settings.get(:storage)
  @moduledoc """
  Proxy layer to provide a Facade for different data storages. The ideia is to read from the config file
  what is the choosen storage, and route the call to the specifc implementation.
  """

  @doc "If you want to know what storage is configured"
  def print_storage(), do: @storage

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

end

