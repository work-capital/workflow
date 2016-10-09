defmodule Account.Event.AccountCreated do
  @derive [Poison.Encoder]
  @type t :: %Account.Event.AccountCreated{}
  defstruct [:id, :date_created]
end
