defmodule RepositoryTest do
  use ExUnit.Case
  require Logger
  alias Engine.EventStore
  alias Engine.Repository


  alias Engine.Example.Account
  alias Engine.Repository



	setup_all do
    #Application.stop(:engine)
    #:ok = Application.start(:engine)
    :ok
  end

  test "add, retrieve and remove PID from cache. Retrieved pid should be the same" do
    :timer.sleep(50)
    {:ok, pid} = Repository.open_aggregate(Account, "AC-1023")

    # for n <- 1..10, do: IO.inspect Process.alive?(pid)  # see the process dying
  end
end

#
#   test "create, operate, load an AGGREGATE to Eventstore, using snapshot and replay" do
#
#     # CONFIGURE FOR SMALL SNAPSHOT PERIOD  [so in 6 operation we make a snapshot!]
#     Application.put_env(:engine, :snapshot_period, 3, timeout: 10000, persistent: false)
#     assert 3 = Engine.Config.get(:snapshot_period)
#
#     # CREATE AN EMPTY AGGREGATE
#     {:ok, pid} = Account.Supervisor.new
#     id = UUID.uuid4
#     Logger.debug "Aggregate ID Created: #{inspect id}"
#
#
#     # 6 OPERATIONS
#     Account.Aggregate.create(pid, id)
#     res1 = Repository.save(pid, Account.Aggregate)
#     Account.Aggregate.deposit(pid, 1000)
#     res1 = Repository.save(pid, Account.Aggregate)
#     Account.Aggregate.withdraw(pid, 500)
#     res1 = Repository.save(pid, Account.Aggregate)
#     Account.Aggregate.deposit(pid, 200)
#     res1 = Repository.save(pid, Account.Aggregate)
#     Account.Aggregate.withdraw(pid, 200)
#     res1 = Repository.save(pid, Account.Aggregate)
#     Account.Aggregate.deposit(pid, 200)
#     res1 = Repository.save(pid, Account.Aggregate)
#
#     Process.sleep(100)
#     last_state = Account.Aggregate.get_state(pid)
#     Logger.debug "Aggregate PID --> 1 Last State: #{inspect last_state}"
#     # STOP [terror...show the process dying...]
#     Account.Aggregate.stop(pid)
#     for n <- 1..10, do: IO.inspect Process.alive?(pid)  # see the process dying
#
#     Process.sleep(100)
#
#     LOAD
#     {:ok, pid2} = Repository.get_by_id(id, Account.Aggregate, Account.Supervisor)
#     #
#     #
#     # last_state = Account.Aggregate.get_state(pid2)
#     #IO.inspect pid2
#     Process.sleep(200)
#     last_state = Account.Aggregate.get_state(pid2)
#     Logger.debug "Aggregate PID --> 2 Last State: #{inspect last_state}"
#
#
#     # 4 OPERATIONS
#     Account.Aggregate.deposit(pid2, 100)
#     res2 = Repository.save(pid2, Account.Aggregate)
#     Account.Aggregate.withdraw(pid2, 50)
#     res2 = Repository.save(pid2, Account.Aggregate)
#     Account.Aggregate.deposit(pid2, 100)
#     res2 = Repository.save(pid2, Account.Aggregate)
#     Account.Aggregate.deposit(pid2, 100)
#     res2 = Repository.save(pid2, Account.Aggregate)
#     # #
#     assert 1 == 1
#     # # CHECK BALANCE [it should have 950 mangos in the account]
#     last_state = Account.Aggregate.get_state(pid2)
#     assert 950 = last_state.balance
#   end
#
# end
#
#
