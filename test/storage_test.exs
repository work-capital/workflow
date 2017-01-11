defmodule Workflow.StorageTest do
  use ExUnit.Case

  #import Commanded.Enumerable, only: [pluck: 2]
  #alias Commanded.Aggregates.{Registry,Aggregate}
  alias Workflow.Storage
  alias Workflow.Metadata

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
    #IO.inspect stream_id
    evts = ExampleAggregate.append_items(%ExampleAggregate{last_index: 0}, 9)
    ev = Enum.at(evts,1)
    metadata = %{"message_id" => "c19df3-2dfds", "correlation_id" => "di3284", "causation_id" => "cause234"}
    #IO.inspect ev
    res = Storage.append_to_stream(stream_id, 0, Enum.at(evts, 1), metadata)
    assert res == :ok
    # again
    # evts2 = ExampleAggregate.append_items(%ExampleAggregate{last_index: 9}, 3)
    # res2 = Storage.append_to_stream(stream_id, 1, Enum.at(evts,2))
    # assert res2 == :ok
  end

  test "read stream forward" do
    stream_id = "storage-test-02-" <> UUID.uuid4
    evts = ExampleAggregate.append_items(%ExampleAggregate{last_index: 0}, 9)
    evt = Enum.at(evts,3)  # let's pick the 4th event
    metadata = %{"message_id" => "c19df3-2dfds", "correlation_id" => "di3284"}
    :ok = Storage.append_to_stream(stream_id, 0, evt, metadata)
    :ok = Storage.append_to_stream(stream_id, 1, evt, metadata)
    res = Storage.append_to_stream(stream_id, 2, evt, metadata)
    assert res == :ok
    {:ok, res2} = Storage.read_stream_forward(stream_id, 0)
    IO.inspect res2
    assert res2 == [{%Workflow.StorageTest.ExampleAggregate.Events.ItemAppended{index: 4},
        %{"correlation_id" => "di3284", "message_id" => "c19df3-2dfds"}},
       {%Workflow.StorageTest.ExampleAggregate.Events.ItemAppended{index: 4},
        %{"correlation_id" => "di3284", "message_id" => "c19df3-2dfds"}},
       {%Workflow.StorageTest.ExampleAggregate.Events.ItemAppended{index: 4},
        %{"correlation_id" => "di3284", "message_id" => "c19df3-2dfds"}}]

    # expected_res = {:ok,
    #   [%Workflow.StorageTest.ExampleAggregate.Events.ItemAppended{index: 4},
    #   %Workflow.StorageTest.ExampleAggregate.Events.ItemAppended{index: 5}]}
    # assert res2 == expected_res
  end
  
  # test "read stream forward for a non-existing stream, and generate error" do
    # stream_id = UUID.uuid4
    # res = Storage.read_stream_forward(stream_id, 0, 2)
    # {error, reason} = res
    # assert error == :error
  # end

end
