defmodule Account.Command.CreateAccount do
  @derive [Poison.Encoder]
  @type t :: %Account.Command.CreateAccount{}
  defstruct [:id]
end
