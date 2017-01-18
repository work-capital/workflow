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
      # generate one event and persist
      ev1 = %Counter{}
        |> Counter.handle(%Add{amount: 9})
      :ok = Persistence.persist_event(ev1, stream_id, 0)

      # generate another event and persist
      ev2 = %Counter{}
        |> Counter.handle(%Remove{amount: 3})
      :ok = Persistence.persist_event(ev2, stream_id, 1)

      # create an empty container data structure
      empty_container = %Container{uuid: stream_id,
                                   module: Workflow.Domain.Counter,
                                   version: 0,
                                   data: %Counter{}}
      # rebuild an aggregate inside a container
      container = Persistence.rebuild_from_events(empty_container, 0)
      assert container = %Workflow.Container{data: %Workflow.Domain.Counter{counter: 6}}
    end



end
