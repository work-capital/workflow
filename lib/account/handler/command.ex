defmodule Account.Handler.Command do
  use AggregateHandler
  require Logger

  ## Commands
  alias Account.Command.CreateAccount
  alias Account.Command.DepositMoney
  alias Account.Command.WithdrawMoney

  ## Acccount Repository
  alias Engine.Repository

  @doc """ 
  Command and pid are automatially available in this scope helped by macro. Note that
  a special flow exists when we receive a command to create a new stream on the database
  for the first time. Generally call this command %Create...blabla{}
  """
  handle_create(%CreateAccount{}, Account.Aggregate, Account.Supervisor) do
    s = Account.Aggregate.create(pid, command.id)
    IO.inspect s
  end

  @doc """
  Normal handle command. You can always add your own implementation instead of using our
  macros, if needed, but generally the command is executed if the PID is found on database 
  """
  handle_command(%DepositMoney{}, Account.Aggregate, Account.Supervisor) do
    Account.Aggregate.deposit(pid, command.amount)
  end




  handle_command(%WithdrawMoney{}, Account.Aggregate, Account.Supervisor) do
    Account.Aggregate.withdraw(pid, command.amount)
  end

end
