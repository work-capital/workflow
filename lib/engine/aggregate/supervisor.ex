defmodule Engine.Aggregate.Supervisor do
  @module __MODULE__
  @moduledoc """
  Supervise zero, one or more event sourced aggregates
  """

  use Supervisor
  require Logger

  def start_link(options), do:
    Supervisor.start_link(@module,:ok, [name: @module])

  def start_aggregate(module, id) do
    Logger.debug(fn -> "starting aggregate process for `#{module}` with id #{id}" end)
    Supervisor.start_child(@module, [module, id])
  end

  #TODO: setup specs, restart strategy, etc.. for supervisors and children
  def init(_) do
    children = [
      worker(Engine.Aggregate.Server, [], restart: :temporary),
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

end
