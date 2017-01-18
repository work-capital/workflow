defmodule Workflow.Domain.Counter do
  defstruct [
    counter: 0
  ]

  # commands & events
  defmodule Commands do
    defmodule Add,    do: defstruct [amount: nil]
    defmodule Remove, do: defstruct [amount: nil]
  end

  defmodule Events do
    defmodule Added,   do: defstruct [amount: nil]
    defmodule Removed, do: defstruct [amount: nil]
  end

  # aliases
  alias Commands.{Add, Remove}
  alias Events.{Added, Removed}
  alias Workflow.Domain.Counter

  # handlers
  def handle(%Counter{counter: counter}, %Add{amount: amount}), do:
    %Added{amount: amount}

  def handle(%Counter{counter: counter}, %Remove{amount: amount}), do:
    %Removed{amount: amount}

  # state mutatators
  def apply(%Counter{counter: counter} = state, %Added{amount: amount}), do:
    %Counter{state | counter: counter + amount}

  def apply(%Counter{counter: counter} = state, %Removed{amount: amount}), do:
    %Counter{state | counter: counter - amount}

end
