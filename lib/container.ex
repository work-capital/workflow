defmodule Workflow.Container do
  @moduledoc """
  Genserver to hold Aggregates or Process Managers
  """
  use GenServer
  require Logger

  # aliases
  alias Workflow.Container
  alias Workflow.Persistence

  defstruct [
    module:       nil,
    uuid:         nil,
    data:         nil,
    version:      0
  ]

  ## API
  def start_link(module, uuid) do
    GenServer.start_link(__MODULE__, %Container{
      module: module,
      uuid:   uuid,
      data: struct(module)
    })
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

  @doc "Replay the events from the eventstore db, from the actual data_state"
  def handle_cast({:restore}, %Container{module: module, data: data, version: version} = state) do
    state = Persistence.rebuild_from_events(%Container{state |
      version: version,
      data: data
    })
    {:noreply, state}
  end

  @doc "Handle a command (for an aggregate) or an event (for the process manager)"
  def handle_call({:process_message, message}, _from, %Container{} = state) do
    #IO.inspect state
    {reply, state} = process(message, state)
    {:reply, reply, state}
  end

  ## INTERNALS

  defp process(message, 
    %Container{uuid: uuid, version: expected_version, data: data, module: module} = state) do
    #IO.inspect "module #{module} data #{data} event #{}"

    event = module.handle(data, message)   # process message for an aggregate or process manager
    new_data = module.apply(data, event) # mutate state

      Persistence.persist_event(event, uuid, expected_version)
      state = %Container{ state |
        data: new_data,
        version: expected_version + 1 # working wiht 1 event only, without buffering
      }
      {:ok, state}
  end


end
