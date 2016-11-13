defmodule Engine.Aggregate.Server do
  @moduledoc """
  Container for aggregates,
  Allows execution of commands against an aggregate and handles persistence of events to the 
  event store.
  https://pdincau.wordpress.com/2013/04/17/how-to-handle-configuration-in-init1-function-without-slowing-down-your-erlang-supervisor-startup/
  """
  use GenServer
  require Logger

  alias Engine.Aggregate.Container
  alias Commanded.Event.Mapper

  ### API
  def start_link(module, uuid), do:
    GenServer.start_link(__MODULE__, %Container{ module: module, uuid: uuid })

  def execute(server, command, handler), do:
    GenServer.call(server, {:execute_command, command, handler})

  def state(server), do:
    GenServer.call(server, {:aggregate})

  ### CALLBACKS
  def init(%Container{} = state) do
    GenServer.cast(self, {:load_events})
    {:ok, state}
  end

  def handle_cast({:load_events}, %Container{} = state) do
    state = load_events(state)
    {:noreply, state}
  end

  def handle_call({:execute_command, command, handler}, _from, %Container{} = state) do
    {reply, state} = execute_command(command, handler, state)
    {:reply, reply, state}
  end

  def handle_call({:aggregate}, _from, %Container{aggregate: aggregate} = state) do
    {:reply, aggregate, state}
  end

  ### PRIVATES
  defp load_events(%Container{module: module, uuid: uuid} = state) do
    aggregate = case EventStore.read_stream_forward(uuid) do
      {:ok, events} -> module.load(uuid, map_from_recorded_events(events))
      {:error, :stream_not_found} -> module.new(uuid)
    end

    # clean event list
    aggregate = %{aggregate | pending_events: []}
    %Container{aggregate | aggregate: aggregate}
  end

  defp execute_command(command, handler, %Container{aggregate: %{version: version} = aggregate} = state) do
    expected_version = version

    with {:ok, aggregate} <- handle_command(handler, aggregate, command),
         {:ok, aggregate} <- persist_events(aggregate, expected_version)
      do {:ok, %Container{aggregate | aggregate: aggregate}}
    else
      {:error, reason} = reply ->
        Logger.warn(fn -> "failed to execute command due to: #{inspect reason}" end)
        {reply, state}
    end
  end

  defp handle_command(handler, state, command) do
    # command handler must return `{:ok, aggregate}` or `{:error, reason}`
    case handler.handle(state, command) do
      {:ok, _aggregate} = reply -> reply
      {:error, _reason} = reply -> reply
    end
  end

  # no pending events to persist, do nothing
  defp persist_events(%{pending_events: []} = state, _expected_version), do: {:ok, state}

  defp persist_events(%{uuid: uuid, pending_events: pending_events} = state, expected_version) do
    correlation_id = UUID.uuid4
    event_data = Mapper.map_to_event_data(pending_events, correlation_id)

    :ok = EventStore.append_to_stream(uuid, expected_version, event_data)

    # clear pending events after appending to stream
    {:ok, %{state | pending_events: []}}
  end

  defp map_from_recorded_events(recorded_events) when is_list(recorded_events) do
    Mapper.map_from_recorded_events(recorded_events)
  end
end
