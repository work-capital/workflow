defmodule Workflow.Supervisor do
  use Supervisor
  @extreme Workflow.Extreme
  @module      __MODULE__
  @stream "persistence-test-01-104355dc-1614-46e1-83cb-a65fcb5fca74"

  def start_link, do: 
    Supervisor.start_link(@module, :ok)


  def init(:ok) do
    event_store_settings = Application.get_env :extreme, :event_store

    children = [
      worker(Extreme,  [event_store_settings, [name: @extreme]]),
      worker(Workflow.Router, [:ok, @extreme])
      # worker(Workflow.Router, [@extreme, -1, [name: Router]])
    ]
    supervise children, strategy: :one_for_one
  end


end
