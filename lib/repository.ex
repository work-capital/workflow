defmodule Workflow.Repository do
  import Supervisor.Spec

  def start_container(module, uuid) do
    {:ok, container} = Workflow.Supervisor.start_container(module, uuid)
    Process.monitor(container)
    container
  end

end
