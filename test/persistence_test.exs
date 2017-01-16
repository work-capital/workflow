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
    # ev1 = %Counter{}
    #   |> Counter.handle(%Add{amount: 7})
    #
    # ev2 = %Counter{}
    #   |> Counter.handle(%Remove{amount: 2})
    #
    # #state = Enum.reduce([ev1, ev2], %Counter{}, &Workflow.Domain.Counter.apply(&2, &1))
    # IO.inspect ev1
    #
    # state = Counter.apply(%Counter{}, ev1)
    # state2 = Counter.apply(state, ev2)
    # # state1 = Workflow.Domain.Counter.apply(%Counter{}, ev2)
    # # state  = Workflow.Domain.Counter.apply(state1, ev1)
    #
    # #state = Persistence.apply_events(Workflow.Domain.Counter, %Counter{}, [ev1, ev2])
    # IO.inspect state2
    #
    # assert 1 == 1
    end


    test "Apply events for a data structure [side-effects]" do
    # stream_id = "persistence-test-01-" <> UUID.uuid4
    #
    # # generate events and persist
    # ev1 = %Counter{}
    #   |> Counter.handle(%Add{amount: 7})
    #
    # :ok = Persistence.persist_events(ev1, stream_id, 0)
    #
    # ev2 = %Counter{}
    #   |> Counter.handle(%Remove{amount: 2})
    #
    # :ok = Persistence.persist_events(ev2, stream_id, 1)
    #
    #
    # # 
    # container = %Container{uuid: stream_id,
    #                        module: Workflow.Domain.Counter,
    #                        version: 0,
    #                        data: %Counter{}}
    #
    # state_data = Persistence.rebuild_from_events(container, 0)
    # #IO.inspect state_data
    #
    # assert 1 == 1
    end



end
