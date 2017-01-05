defmodule Workflow do
  use Application
  require Logger
  @doc "Start the supervisor and activate its handlers"
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    children = [
      supervisor(Workflow.Extreme.Supervisor, [], restart: :permanent),
      supervisor(Workflow.Supervisor, [], restart: :permanent),
    ]
    opts = [strategy: :one_for_one, name: Workflow.Supervisor2]
    Supervisor.start_link(children, opts)
    # start containter supervisor for simple_one_to_one workers
    #Workflow.ContainerSup.start_link()
  end


end
