defmodule Account.Event.MoneyDeposited do
  @derive [Poison.Encoder]
  @type t :: %Account.Event.MoneyDeposited{}
  defstruct [:id, :amount, :new_balance, :transaction_date]
end
