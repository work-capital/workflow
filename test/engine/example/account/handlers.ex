defmodule Engine.Example.DepositMoneyHandler do
  alias Engine.Example.Account
  alias Engine.Example.Account.Commands.DepositMoney

  @behaviour Engine.Commands.Handler

  def handle(%Account{} = aggregate, %DepositMoney{} = deposit_money) do
    aggregate
    |> Account.deposit(deposit_money)
  end
end


defmodule Engine.Example.OpenAccountHandler do
  alias Engine.Example.Account
  alias Engine.Example.Account.Commands.{OpenAccount,CloseAccount}

  @behaviour Engine.Commands.Handler

  def handle(%Account{} = aggregate, %OpenAccount{} = open_account) do
    aggregate
    |> Account.open_account(open_account)
  end

  def handle(%Account{} = aggregate, %CloseAccount{} = close_account) do
    aggregate
    |> Account.close_account(close_account)
  end
end



defmodule Engine.Example.WithdrawMoneyHandler do
  alias Engine.Example.Account
  alias Engine.Example.Account.Commands.WithdrawMoney

  @behaviour Engine.Commands.Handler

  def handle(%Account{} = aggregate, %WithdrawMoney{} = withdraw_money) do
    aggregate
    |> Account.withdraw(withdraw_money)
  end
end
