defmodule Account.Command.WithdrawMoney do
  @derive [Poison.Encoder]
  @type t :: %Account.Command.WithdrawMoney{}
  defstruct [:id, :amount]
end
