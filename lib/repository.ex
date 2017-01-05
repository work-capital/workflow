defmodule Workflow.Repository do
  import Supervisor.Spec
  @module_doc """
  It will give you a container pid, if it is on memory, will get from memory, but if it's not
  on memory, it will replay all events, reach the last state, save on cache memory, and give 
  it to you. :)
  """

  def start_container(module, uuid) do
    {:ok, container} = Workflow.Supervisor.start_container(module, uuid)
    Process.monitor(container)
    container
  end

end
