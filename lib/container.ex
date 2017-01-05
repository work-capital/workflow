defmodule Workflow.Container do
  @moduledoc """
  Genserver to hold Aggregates or Process Managers
  """
  use GenServer
  require Logger
  
  alias Workflow.Container
  alias Workflow.Persistence

  defstruct [
    module:       nil,
    uuid:         nil,
    data:         nil,
    version:      nil
  ]

  ## API

  def start_link(module, uuid) do
    GenServer.start_link(__MODULE__, %Container{
      module: module,
      uuid:   uuid
    })
  end

  def execute() do
  end

  def get_data(container), do:
    GenServer.call(container, {:data})

  def get_state(container), do:
    GenServer.call(container, {:state})

  def process_message(container, message), do:
    GenServer.call(container, {:process_message, message})


  ## CALLBACKS
  
  def init(%Container{} = state) do
    GenServer.cast(self, {:restore})
    {:ok, state}
  end

  def handle_call({:data}, _from, %Container{data: data} = state), do:
    {:reply, data, state}

  def handle_call({:state}, _from, %Container{} = state), do:
    {:reply, state, state}

  def handle_cast({:restore}, %Container{module: module} = state) do
    state = Persistence.rebuild_from_events(%Container{state |
      version: 0,
      data: struct(module) # empty data structure to be filled
    })
    {:noreply, state}
  end

  @doc "Handle a command (for an aggregate) or an event (for the process manager)"
  def handle_call({:process_message, message}, _from, %Container{} = state) do
    {reply, state} = process(message, state)
    {:reply, reply, state}
  end

  ## INTERNALS

  defp process(message, 
    %Container{uuid: uuid, version: expected_version, data: data, module: module} = state) do
      event = module.handle(data, message)   # process message for an aggregate or process manager
      wrapped_event = List.wrap(event)

      new_data = Persistence.apply_events(module, data, wrapped_event)
      Persistence.persist_events(wrapped_event, uuid, expected_version)
      state = %Container{ state |
        data: new_data,
        version: expected_version + length(wrapped_event)
      }
      {:ok, state}
  end

  # update the process instance's state by applying the event
  def mutate_state(module, data, event), do:
    module.apply(data, event)


end
