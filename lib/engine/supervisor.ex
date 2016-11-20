defmodule Engine.Supervisor do
  use Supervisor
  @docmodule """
  this is the main application supervisor, we start from here the Extreme driver to communicate with Eventstore
  database, and start the Bus, that all aggregators, processes managers, etc... will handle
  """
  @event_store Engine.EventStore
  @module      __MODULE__

  def start_link, do: Supervisor.start_link(@module, :ok)


  def init(:ok) do
    event_store_settings = Application.get_env :extreme, :event_store

    children = [
      supervisor(Task.Supervisor, [[name: Engine.Command.TaskDispatcher]]),
      worker(Extreme,  [event_store_settings, [name: @event_store]]),
      worker(Engine.Bus, [], restart: :temporary)
    ]
    supervise children, strategy: :one_for_one
  end


end

