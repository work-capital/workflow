defmodule Workflow.PersistenceTest do
  use ExUnit.Case

  # persistence
  alias Workflow.Persistence
  alias Workflow.Container

  # domain data structures
  alias Workflow.Domain.Counter
  alias Counter.Commands.{Add, Remove}
  alias Counter.Events.{Added, Removed}

    test "Clean metadata function [pure]" do
      # events with metadata
      with_meta = [{%Workflow.Domain.Counter.Events.Added{amount: 5}, nil},
                   {%Workflow.Domain.Counter.Events.Removed{amount: -2}, nil},
                   {%Workflow.Domain.Counter.Events.Added{amount: 7}, nil},
                   {%Workflow.Domain.Counter.Events.Removed{amount: -3}, nil}]

      # cleaned events
      without_meta = Persistence.clean_metadata(with_meta)
      expected_result = [%Workflow.Domain.Counter.Events.Added{amount: 5},
                         %Workflow.Domain.Counter.Events.Removed{amount: -2},
                         %Workflow.Domain.Counter.Events.Added{amount: 7},
                         %Workflow.Domain.Counter.Events.Removed{amount: -3}]

      assert without_meta = expected_result
    end


    test "Apply events to a data structue (Aggregate, Process Manager, etc.) [pure]" do
      ev1 = %Counter{}
        |> Counter.handle(%Add{amount: 7})

      ev2 = %Counter{}
        |> Counter.handle(%Remove{amount: 2})

      state = Persistence.apply_events(Workflow.Domain.Counter, %Counter{}, [ev1, ev2])
      assert state == %Workflow.Domain.Counter{counter: 5}
    end


    test "Apply events for a data structure [side-effects]" do
      stream_id = "persistence-test-01-" <> UUID.uuid4
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

      # persist them
      :ok = Persistence.persist_events(event_list, stream_id, 0)
      :ok = Persistence.persist_events(event_list, stream_id, 2)

      # persists, but answers a sync error (here version should be 4)
      {:error, UnsyncVersion} = Persistence.persist_events(event_list, stream_id, 9)

      # create an empty container data structure
      empty_container = %Container{uuid: stream_id,
                                   module: Workflow.Domain.Counter,
                                   version: 0,
                                   data: %Counter{}}

      # rebuild an aggregate inside a container
      container = Persistence.rebuild_from_events(empty_container, 0)
      assert container = %Workflow.Container{data: %Workflow.Domain.Counter{counter: 15},
                                             module: Workflow.Domain.Counter,
                                             uuid: "persistence-test-01-8c343a9e-88e8-449d-9501-cd2161fc777b",
                                             version: 5}
    end



end
