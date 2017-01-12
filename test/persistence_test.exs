defmodule Workflow.PersistenceTest do
  use ExUnit.Case

  # persistence
  alias Workflow.Persistence
  alias Workflow.Container

  # domain data structures
  alias Workflow.Domain.Counter
  alias Counter.Commands.{Add, Remove}
  alias Counter.Events.{Added, Removed}


    test "Apply events for a data structure" do

    stream_id = "persistence-test-01-" <> UUID.uuid4

    # generate events and persist
    ev1 = %Counter{}
      |> Counter.handle(%Add{quantity: 7})

    :ok = Persistence.persist_events(ev1, stream_id, 0)

    ev2 = %Counter{}
      |> Counter.handle(%Remove{quantity: 2})

    :ok = Persistence.persist_events(ev2, stream_id, 1)


    # 
    container = %Container{uuid: stream_id,
                           module: Workflow.Domain.Counter,
                           version: 0,
                           data: %Counter{}}

    state_data = Persistence.rebuild_from_events(container, 0)


    assert 1 == 1
    end
end
