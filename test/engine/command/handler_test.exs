defmodule Engine.Command.HandleTest do
  use ExUnit.Case

  alias Engine.Example.Account
  alias Engine.Example.Account.OpenAccountHandler
  alias Engine.Example.Account.Commands.OpenAccount
  alias Engine.Example.Account.Events.AccountOpened

  test "command handler implements behaviour" do
    initial_state = %Account{}
    event = OpenAccountHandler.handle(initial_state, %OpenAccount{account_number: "ACC123", initial_balance: 1_000})

    assert event == %AccountOpened{account_number: "ACC123", initial_balance: 1_000}
    assert Account.apply(initial_state, event) == %Account{
      account_number: "ACC123",
      balance: 1_000,
      state: :active,
    }
  end
end
