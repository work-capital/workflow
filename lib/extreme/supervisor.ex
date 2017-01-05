defmodule Workflow.Extreme.Supervisor do
  use Supervisor
  @extreme Workflow.Extreme
  @module      __MODULE__

  def start_link, do: 
    Supervisor.start_link(@module, :ok, name: @module)


  def init(:ok) do
    event_store_settings = Application.get_env :extreme, :event_store

    children = [
      worker(Extreme,  [event_store_settings, [name: @extreme]], restart: :permanent),
      worker(Workflow.Extreme.Router, [:ok, @extreme])
      # worker(Workflow.Router, [@extreme, -1, [name: Router]])
    ]
    supervise(children, strategy: :one_for_all)   # if we lost connection, we restart the router also
  end


end
