defmodule Workflow.Supervisor do
  @module __MODULE__
  @moduledoc """
  Supervise zero, one or more containers
  """
  use Supervisor
  require Logger

  def start_link, do:
    Supervisor.start_link(__MODULE__, :ok, name: @module)

  def start_container(module, uuid) do
    Logger.debug(fn -> "starting process for `#{module}` with uuid #{uuid}" end)
    Supervisor.start_child(Workflow.Supervisor, [module, uuid])
  end

  def init(:ok) do
    children = [
      worker(Workflow.Container, [], restart: :permanent),
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
