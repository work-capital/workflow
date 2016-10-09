defmodule CommandHandlerTest do
  use ExUnit.Case
  require Logger
  alias Engine.EventStore
  alias Engine.Repository


	setup_all do
    Application.stop(:engine)
    :ok = Application.start(:engine)
  end

  test "send events to command handler and check if they were accepted" do

    id   = UUID.uuid4
    res  = Engine.Bus.send_command(%{%Account.Command.CreateAccount{} | id: id})
    Process.sleep(100)  # if you don't sleep, the next command can't find by id !

    res1 = Engine.Bus.send_command(%{%Account.Command.DepositMoney{}  | id: id, amount: 260})
    res1 = Engine.Bus.send_command(%{%Account.Command.DepositMoney{}  | id: id, amount: 40})
    res1 = Engine.Bus.send_command(%{%Account.Command.DepositMoney{}  | id: id, amount: 30})
    Process.sleep(100)

    {:ok, pid} = Repository.get_by_id(id, Account.Aggregate, Account.Supervisor)
    Account.Aggregate.stop(pid)
    Process.sleep(100)
    for n <- 1..10, do: IO.inspect Process.alive?(pid)  # see the process dying

    # LOAD
    {:ok, pid2} = Repository.get_by_id(id, Account.Aggregate, Account.Supervisor)

    last_state = Account.Aggregate.get_state(pid2)
    assert res  == :ok
    assert res1 == :ok
    assert 330 = last_state.balance
  end



end


