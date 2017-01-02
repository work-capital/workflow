defmodule Workflow.Supervisor do
  use Supervisor
  @event_store Workflow.EventStore
  @module      __MODULE__

  def start_link, do: Supervisor.start_link __MODULE__, :ok


  def init(:ok) do
    event_store_settings = Application.get_env :extreme, :event_store

    children = [
      worker(Extreme,  [event_store_settings, [name: @event_store]]),
      #worker(Workflow.Router, [], restart: :temporary)
    ]
    supervise children, strategy: :one_for_one
  end


end
