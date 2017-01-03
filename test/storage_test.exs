defmodule Workflow.StorageTest do
  use ExUnit.Case

  #import Commanded.Enumerable, only: [pluck: 2]
  #alias Commanded.Aggregates.{Registry,Aggregate}
  alias Workflow.Storage

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

    def append_items(%ExampleAggregate{last_index: last_index}, count), do:
      Enum.map(1..count, fn index -> %ItemAppended{index: last_index + index} end)

    # state mutatators
    def apply(%ExampleAggregate{items: items} = state, %ItemAppended{index: index}) do
      %ExampleAggregate{state |
        items: items ++ [index],
        last_index: index,
      }
    end
  end

  alias ExampleAggregate.Commands.{AppendItems}


  test "should append events to stream" do
    config  = Application.get_env(:workflow, :adapter, [])
    stream_id = "storage-test-01-" <> UUID.uuid4
    evts = ExampleAggregate.append_items(%ExampleAggregate{last_index: 0}, 9)
    res = Storage.append_to_stream(stream_id, 0, evts)
    assert res == :ok
    # again
    evts2 = ExampleAggregate.append_items(%ExampleAggregate{last_index: 9}, 3)
    res2 = Storage.append_to_stream(stream_id, 9, evts)
    assert res2 == :ok
  end

  test "read stream forward" do
    stream_id = "storage-test-02-" <> UUID.uuid4
    evts = ExampleAggregate.append_items(%ExampleAggregate{last_index: 0}, 9)
    res  = Storage.append_to_stream(stream_id, 0, evts)
    res2 = Storage.read_stream_forward(stream_id, 3, 2)
    expected_res = {:ok,
      [%Workflow.StorageTest.ExampleAggregate.Events.ItemAppended{index: 4},
      %Workflow.StorageTest.ExampleAggregate.Events.ItemAppended{index: 5}]}
    assert res2 == expected_res
  end

end
