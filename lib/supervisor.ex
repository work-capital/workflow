defmodule Workflow.Supervisor do
  use Supervisor
  @extreme Workflow.Extreme
  @module      __MODULE__

  def start_link, do: Supervisor.start_link __MODULE__, :ok


  def init(:ok) do
    event_store_settings = Application.get_env :extreme, :event_store

    children = [
      worker(Extreme,  [event_store_settings, [name: @extreme]])
      #worker(Workflow.Container, []),
      #worker(Workflow.Router, [], restart: :temporary)
    ]
    supervise children, strategy: :one_for_one
  end


end
