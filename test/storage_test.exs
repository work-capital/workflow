defmodule Workflow.StorageTest do
  use ExUnit.Case

  #import Commanded.Enumerable, only: [pluck: 2]
  #alias Commanded.Aggregates.{Registry,Aggregate}
  alias Workflow.Storage

  # domain data structures
  alias Workflow.Domain.Counter
  alias Counter.Commands.{Add, Remove}
  alias Counter.Events.{Added, Removed}



  test "should append events as list, with data and metadata, to stream" do
    config  = Application.get_env(:workflow, :adapter, [])
    stream_id = "storage-test-01-" <> UUID.uuid4

    # event 1
    ev1 = %Counter{}
      |> Counter.handle(%Add{amount: 7})

    meta1 = %{"message_id"     => "c19df3-2dfds",
              "correlation_id" => "di3284",
              "causation_id"   => "cause234"}
    # event 2
    ev2 = %Counter{}
      |> Counter.handle(%Remove{amount: 2})

    meta2 = %{"message_id"     => "a93234-2fe32",
              "correlation_id" => "u234",
              "causation_id"   => "cause993"}
    # join them
    event_list = [ {ev1, meta1}, {ev2, meta2} ]

    # write stream from zero position
    res = Storage.append_to_stream(stream_id, 0, event_list)
    assert res == :ok

    # write again expecting position 2
    res2 = Storage.append_to_stream(stream_id, 2, event_list)
    assert res2 == :ok

  end

  test "read stream forward" do
     stream_id = "storage-test-02-" <> UUID.uuid4
     evts = [{%Workflow.Domain.Counter.Events.Added{amount: 7},
            %{"causation_id" => "22-cause24",
              "message_id" => "44-c19df3-2dfds"}},

             {%Workflow.Domain.Counter.Events.Removed{amount: 2},
            %{"correlation_id" => "99-u234",
              "message_id" => "88-a93234-2fe32"}},

             {%Workflow.Domain.Counter.Events.Added{amount: 4},
            %{"causation_id" => "1-cause234",
              "correlation_id" => "32-di3284",
              "message_id" => "38-c19df3-2dfds"}},

             {%Workflow.Domain.Counter.Events.Removed{amount: 9},
            %{"message_id" => "9a93234-2fe32"}},

             {%Workflow.Domain.Counter.Events.Added{amount: 1},
            %{"causation_id" => "91-cause23",
              "correlation_id" => "832-di3284",
              "message_id" => "3c19df3-2dfds"}},

             {%Workflow.Domain.Counter.Events.Removed{amount: 8},
            %{"causation_id" => "cause3993",
              "correlation_id" => "982-u234",
              "message_id" => "1a93234-2fe32"}}]

    res = Storage.append_to_stream(stream_id, 0, evts)

    # read from version 2, batch size 1
    {:ok, res2} = Storage.read_stream_forward(stream_id, 2, 1)  # read batch size of 3 events
    assert res2 = Enum.fetch!(evts, 2)

    # read from version 0, batch of 3 events
    {:ok, res3} = Storage.read_stream_forward(stream_id, 0, 3)  # read batch size of 3 events
    assert res3 = Enum.take(evts, 3)
  end

  test "read stream forward for a non-existing stream, and generate error" do
    stream_id = UUID.uuid4
    res = Storage.read_stream_forward(stream_id, 0, 2)
    {error, reason} = res
    assert error == :error
  end

end
