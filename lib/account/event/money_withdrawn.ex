defmodule Account.Event.MoneyWithdrawn do
  @derive [Poison.Encoder]
  @type t :: %Account.Event.MoneyWithdrawn{}
  defstruct [:id, :amount, :new_balance, :transaction_date]
end
