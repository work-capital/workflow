defmodule Workflow.ContainerSup do
  @name Workflow.ContainerSup
  @moduledoc """
  Supervise zero, one or more containers
  """
  use Supervisor
  require Logger

  def start_link, do:
    Supervisor.start_link(__MODULE__, :ok, name: @name)

  def start_container(module, uuid) do
    Logger.debug(fn -> "starting process for `#{module}` with uuid #{uuid}" end)
    Supervisor.start_child(Workflow.ContainerSup, [module, uuid])
  end

  def init(:ok) do
    children = [
      worker(Workflow.Container, [], restart: :temporary),
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
