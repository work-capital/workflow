defmodule Account.Command.DepositMoney do
  @derive [Poison.Encoder]
  @type t :: %Account.Command.DepositMoney{}
  defstruct [:id, :amount]
end
