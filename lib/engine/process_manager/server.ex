defmodule Engine.ProcessManager.Server do
  @module __MODULE__
  @moduledoc """
  Container for aggregates. For the sake of non-ambiguity, we use the name 'container' for the state of 
  this gen_server, and 'state' for the data structure. 
  Allows execution of commands against an aggregate and handles persistence of events to the 
  event store.
  """
  use GenServer
  require Logger

  alias Engine.Container          # this is the internal state
  alias Commanded.Event.Mapper

  ### API ##############


  @doc "Start suitable for process manager"
  def start_link(module, uuid, name, dispatcher) do
    GenServer.start_link(@module, %Container{
      module: module,
      uuid: uuid,
      name: name,
      state: module.new(uuid),
      dispatcher: dispatcher
    })
  end

  @doc "Execute command over an aggregate or processmanager"
  def execute(pid, command, handler), do:
    GenServer.call(pid, {:execute_command, command, handler})

  @doc "Handle the given event by delegating to the process manager module"
  def process_event(pid, %EventStore.RecordedEvent{} = event, process_router), do:
    GenServer.cast(pid, {:process_event, event, process_router})

  @doc "Get the state of this genserver"
  def state(pid), do:
    GenServer.call(pid, {:get_state})


  ### CALLBACKS #########

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

  def handle_call({:aggregate}, _from, %Container{state: aggregate} = state) do
    {:reply, aggregate, state}
  end

  ### PRIVATES
  defp load_events(%Container{module: module, uuid: uuid} = state) do
    # aggregate = case EventStore.read_stream_forward(uuid) do
    #   {:ok, events} -> module.load(uuid, map_from_recorded_events(events))
    #   {:error, :stream_not_found} -> module.new(uuid)
    # end

    # # clean event list
    # aggregate = %{aggregate | pending_events: []}
    # %Container{aggregate | state: aggregate}
  end

  defp execute_command(command, handler, %Container{state: %{version: version} = aggregate} = container) do
    # expected_version = version
    #
    # with {:ok, aggregate} <- handle_command(handler, aggregate, command),
    #      {:ok, aggregate} <- persist_events(aggregate, expected_version)
    #   do {:ok, %Container{container | state: state}}
    # else
    #   {:error, reason} = reply ->
    #     Logger.warn(fn -> "failed to execute command due to: #{inspect reason}" end)
    #     {reply, container}
    # end
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
