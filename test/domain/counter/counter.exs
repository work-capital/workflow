defmodule Workflow.Domain.Counter do
  defstruct [
    counter: 0
  ]

  # commands & events
  defmodule Commands do
    defmodule Add,    do: defstruct [quantity: nil]
    defmodule Remove, do: defstruct [quantity: nil]
  end

  defmodule Events do
    defmodule Added,   do: defstruct [counter: nil]
    defmodule Removed, do: defstruct [counter: nil]
  end

  # aliases
  alias Commands.{Add, Remove}
  alias Events.{Added, Removed}
  alias Workflow.Domain.Counter

  # handlers
  def handle(%Counter{counter: counter}, %Add{quantity: quantity}) do
    new_counter = counter + quantity
    %Added{counter: new_counter}
  end

  def handle(%Counter{counter: counter}, %Remove{quantity: quantity}) do
    new_counter = counter - quantity
    %Removed{counter: new_counter}
  end

  # state mutatators
  def apply(%Counter{} = state, %Added{counter: counter}), do:
    %Counter{state | counter: counter }

  def apply(%Counter{} = state, %Removed{counter: counter}), do:
    %Counter{state | counter: counter }
end
