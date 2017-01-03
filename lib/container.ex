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


  ## CALLBACKS
  
  def init(%Container{} = state) do
    GenServer.cast(self, {:replay})
    {:ok, state}
  end

  def handle_cast({:replay}, %Container{} = state) do
    state = replay(state)
    {:noreply, state}
  end

  ## INTERNALS

  defp replay(%Container{module: module} = state) do
    Persistence.rebuild_from_events(%Container{state |
      version: 0,
      data: struct(module)
    })
  end

  defp execute(message, %Container{uuid: uuid, version: expected_version, data: data, module: aggregate_module} = state) do
    # case Kernel.apply(handler, function, [aggregate_state, command]) do
    #   {:error, _reason} = reply -> {reply, state}
    #   nil -> {:ok, state}
    #   [] -> {:ok, state}
    #   events ->
    #     pending_events = List.wrap(events)
    #
    #     updated_state = Persistence.apply_events(aggregate_module, aggregate_state, pending_events)
    #
    #     :ok = Persistence.persist_events(pending_events, aggregate_uuid, expected_version)
    #
    #     state = %Container{state |
    #       state: updated_state,
    #       version: expected_version + length(pending_events),
    #     }
    #
    #     {:ok, state}
    # end
  end



end
