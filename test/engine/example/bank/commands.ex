  ### COMMANDS
  defmodule Engine.Example.Bank.Commands do
    defmodule TransferMoney, do: defstruct transfer_uuid: UUID.uuid4, source_account: nil, target_account: nil, amount: nil
  end
