  ### EVENTS
  defmodule Engine.Example.Account.Events do
    defmodule AccountOpened,   do: defstruct [:account_number, :initial_balance]
    defmodule MoneyDeposited,  do: defstruct [:account_number, :transfer_uuid, :amount, :balance, :source]
    defmodule MoneyWithdrawn,  do: defstruct [:account_number, :transfer_uuid, :amount, :balance, :target]
    defmodule AccountClosed,   do: defstruct [:account_number]
  end
