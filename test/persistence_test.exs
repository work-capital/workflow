defmodule Workflow.PersistenceTest do
  use ExUnit.Case

  defmodule ExampleAggregate do
    defstruct [
      items: [],
      last_index: 0,
    ]

    # command & event
    defmodule Commands, do: defmodule AppendItems, do: defstruct [count: 0]
    defmodule Events, do: defmodule ItemAppended, do: defstruct [index: nil]

    alias Commands.{AppendItems}
    alias Events.{ItemAppended}

    def append_items(%ExampleAggregate{last_index: last_index}, count) do
      Enum.map(1..count, fn index ->
        %ItemAppended{index: last_index + index}
      end)
    end

    def append_item(%ExampleAggregate{last_index: last_index}, %AppendItems{count: count}) do
      %ItemAppended{index: last_index + 1}
    end

    # state mutatators
    def apply(%ExampleAggregate{items: items} = state, %ItemAppended{index: index}) do
      %ExampleAggregate{state |
        items: items ++ [index],
        last_index: index,
      }
    end
  end

  alias ExampleAggregate.Commands.{AppendItems}
  alias Workflow.Persistence



  test "Apply events for a data structure" do

    aggregate = %ExampleAggregate{}

    events = ExampleAggregate.append_items(aggregate, 6)
    res = Persistence.persist_events(events, "id-02", 0)

    res = Persistence.apply_events(ExampleAggregate, aggregate, events)


    last_state = %ExampleAggregate{items: [1, 2, 3, 4, 5, 6], last_index: 6}
    assert res = last_state
  end
end
