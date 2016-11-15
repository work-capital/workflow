defmodule Engine.ExampleDomain.DepositMoneyHandler do
  alias Engine.ExampleDomain.BankAccount
  alias Engine.ExampleDomain.BankAccount.Commands.DepositMoney

  @behaviour Engine.Commands.Handler

  def handle(%BankAccount{} = aggregate, %DepositMoney{} = deposit_money) do
    aggregate
    |> BankAccount.deposit(deposit_money)
  end
end



defmodule Engine.ExampleDomain.OpenAccountHandler do
  alias Engine.ExampleDomain.BankAccount
  alias Engine.ExampleDomain.BankAccount.Commands.{OpenAccount,CloseAccount}

  @behaviour Engine.Commands.Handler

  def handle(%BankAccount{} = aggregate, %OpenAccount{} = open_account) do
    aggregate
    |> BankAccount.open_account(open_account)
  end

  def handle(%BankAccount{} = aggregate, %CloseAccount{} = close_account) do
    aggregate
    |> BankAccount.close_account(close_account)
  end
end



defmodule Engine.ExampleDomain.WithdrawMoneyHandler do
  alias Engine.ExampleDomain.BankAccount
  alias Engine.ExampleDomain.BankAccount.Commands.WithdrawMoney

  @behaviour Engine.Commands.Handler

  def handle(%BankAccount{} = aggregate, %WithdrawMoney{} = withdraw_money) do
    aggregate
    |> BankAccount.withdraw(withdraw_money)
  end
end
