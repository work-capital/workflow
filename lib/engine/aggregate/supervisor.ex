defmodule Engine.Aggregate.Supervisor do
  @module __MODULE__
  @moduledoc """
  Supervise zero, one or more event sourced aggregates
  """

  use Supervisor
  require Logger

  def start_link, do:
    Supervisor.start_link(@module, nil)

  def start_aggregate(supervisor, module, id) do
    Logger.debug(fn -> "starting aggregate process for `#{module}` with id #{id}" end)
    Supervisor.start_child(supervisor, [module, id])
  end

  def init(_) do
    children = [
      worker(Commanded.Aggregates.Aggregate, [], restart: :temporary),
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

end
