defmodule Account.Event.PaymentDeclined do
  @derive [Poison.Encoder]
  @type t :: %Account.Event.PaymentDeclined{}
  defstruct [:id, :amount, :transaction_date]
end
