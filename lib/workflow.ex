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
    opts = [strategy: :one_for_one, name: Workflow.Application]
    Supervisor.start_link(children, opts)
  end


end
