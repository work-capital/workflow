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

    stream_id = "persistence-test-01-" <> UUID.uuid4
    aggregate = %ExampleAggregate{}

    events = ExampleAggregate.append_items(aggregate, 6)
    res = Persistence.persist_events(events, stream_id, 0)
    state = Persistence.apply_events(ExampleAggregate, aggregate, events)

    last_state = %ExampleAggregate{items: [1, 2, 3, 4, 5, 6], last_index: 6}
    assert state == last_state

    events2 = ExampleAggregate.append_items(aggregate, 2)
    res2   = Persistence.persist_events(events2, stream_id, 6)
    state2 = Persistence.apply_events(ExampleAggregate, aggregate, events2)

    last_state2   = %ExampleAggregate{items: [1, 2], last_index: 2}
    assert state2 == last_state2

  end
end
