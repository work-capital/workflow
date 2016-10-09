defmodule Account.Supervisor do
  use AggregateSupervisor
  @module __MODULE__
  @moduledoc """
  Note that we use 'temporary' restart strategy, once if it get killed, the only loss is
  not having this pid on cache, and it will be rebuilt on the next command call. Anyway,
  it's good that the process is attached to it's supervisor.
  TODO: continue the DSL for the AggregateSupervisor macro, like:
    defsupervisor init(add_handler(), Acount.Aggregate)
  """

  def init(_) do
    Account.Handler.Command.add_handler()
    children = [
      worker(Account.Aggregate, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end


end
