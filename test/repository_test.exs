defmodule RepositoryTest do
  use ExUnit.Case

  alias Workflow.Container
  alias Workflow.Domain.Account
  alias Workflow.Repository

  defmodule CounterAggregate do
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

    # handlers
    def handle(%CounterAggregate{counter: counter}, %Add{quantity: quantity}) do
      new_counter = counter + quantity
      %Added{counter: new_counter}
    end

    def handle(%CounterAggregate{counter: counter}, %Remove{quantity: quantity}) do
      new_counter = counter - quantity
      %Removed{counter: new_counter}
    end

    # state mutatators
    def apply(%CounterAggregate{} = state, %Added{counter: counter}), do:
      %CounterAggregate{state | counter: counter }

    def apply(%CounterAggregate{} = state, %Removed{counter: counter}), do:
      %CounterAggregate{state | counter: counter }
  end

  alias CounterAggregate.Commands.{Add, Remove}
  alias CounterAggregate.Events.{Added, Removed}


  test "simulation using pure functional data structures" do
    # generate event
    ev1 = %CounterAggregate{}
      |> CounterAggregate.handle(%Add{quantity: 7})

    # apply
    c = %CounterAggregate{}
      |> CounterAggregate.apply(ev1)

    # generate event over the last state
    ev2 = c |> CounterAggregate.handle(%Remove{quantity: 3})

    # apply
    c2 = %CounterAggregate{}
      |> CounterAggregate.apply(ev2)

    assert c2 == %CounterAggregate{counter: 4} 
  end


  test "simulate using side effects" do
    # stream_id = "repository-test-01-" <> UUID.uuid4
    # container = Repository.start_container(CounterAggregate, stream_id)
    # # process two commands
    # res1 = Container.process_message(container, %Add{quantity: 7})
    # res2 = Container.process_message(container, %Remove{quantity: 3})
    # # get state data
    # data = Container.get_data(container)
    # state = Container.get_state(container)
    # IO.inspect state
    # IO.inspect res1
    #
    # assert data== %CounterAggregate{counter: 4}  #  7 - 3 = 4
  end


end
