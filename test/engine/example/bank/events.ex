  ### EVENTS
  defmodule Engine.Example.Bank.Events do
    defmodule MoneyTransferRequested, do: defstruct transfer_uuid: nil, source_account: nil, target_account: nil, amount: nil
    defmodule MoneyTransferSucceeded, do: defstruct transfer_uuid: nil, source_account: nil, target_account: nil, amount: nil
    defmodule MoneyTransferFailed,    do: defstruct transfer_uuid: nil, source_account: nil, target_account: nil, amount: nil
  end
