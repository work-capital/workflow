  ### COMMANDS
  defmodule Engine.Example.Account.Commands do
    defmodule OpenAccount,     do: defstruct [:account_number, :initial_balance]
    defmodule DepositMoney,    do: defstruct [:account_number, :transfer_uuid, :amount, :source]
    defmodule WithdrawMoney,   do: defstruct [:account_number, :transfer_uuid, :amount, :target]
    defmodule CloseAccount,    do: defstruct [:account_number]
  end
