defmodule Engine.Aggregate.Server do
  @module __MODULE__
  @moduledoc """
  Container for aggregates. For the sake of non-ambiguity, we use the name 'container' for the state of 
  this gen_server, and 'state' for the data structure. 
  GENSERVER  ->  CONTAINER  -> STATE (Aggregate or Process Manager Data Structure Macros)
  Allows execution of commands against an aggregate and handles persistence of events to the 
  event store.
  """
  use GenServer
  require Logger

  alias Engine.Container          # this is the internal state
  alias Commanded.Event.Mapper

  ### API ##############


  @doc "Start, suitable for aggregates"
  def start_link(module, uuid), do:
    GenServer.start_link(@module, %Container{ module: module, uuid: uuid })

  @doc "Execute command over an aggregate or processmanager"
  def execute(pid, command, handler), do:
    GenServer.call(pid, {:execute_command, command, handler})

  @doc "Get the state of this genserver"
  def get_container(pid), do:
    GenServer.call(pid, {:get_container})


  ### CALLBACKS #########

  def init(%Container{} = container) do
    GenServer.cast(self, {:rehydrate})
    {:ok, container}
  end

  def handle_cast({:rehydrate}, %Container{module: module, uuid: uuid} = container), do:
    {:noreply, Container.rehydrate(container)}

  def handle_call({:get_container}, _from, %Container{state: state} = container), do:
    {:reply, container, container}

  def handle_call({:execute_command, command, handler}, _from, %Container{} = state) do
    {reply, state} = execute_command(command, handler, state)
    {:reply, reply, state}
  end

  defp handle_command(handler, state, command) do
    # command handler must return `{:ok, aggregate}` or `{:error, reason}`
    case handler.handle(state, command) do
      {:ok, _aggregate} = reply -> reply
      {:error, _reason} = reply -> reply
    end
  end

  ### INTERNALS #######
  #
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

end
