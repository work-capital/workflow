defmodule Engine.AggregateTest do
  use ExUnit.Case
  #doctest EventSourced.Aggregate

  defmodule ExampleAggregate do
    use Engine.Aggregate, fields: [name: ""]

    defmodule Events.NameAssigned do
      defstruct name: ""
    end

    def assign_name(%ExampleAggregate{} = aggregate, name) do
      aggregate
      |> update(%Events.NameAssigned{name: name})
    end

    def apply(%ExampleAggregate.State{} = state, %Events.NameAssigned{} = name_assigned) do
      %ExampleAggregate.State{state |
        name: name_assigned.name
      }
    end
  end

  test "assigns aggregate fields to state struct" do
    aggregate = ExampleAggregate.new("uuid")

    assert aggregate.state == %ExampleAggregate.State{name: ""}
    assert aggregate.uuid == "uuid"
    assert aggregate.version == 0
    assert length(aggregate.pending_events) == 0
  end

  test "applies event" do
    aggregate =
      ExampleAggregate.new("uuid")
      |> ExampleAggregate.assign_name("Ben")

    assert aggregate.state == %ExampleAggregate.State{name: "Ben"}
    assert aggregate.uuid == "uuid"
    assert aggregate.version == 1
    assert length(aggregate.pending_events) == 1
  end

  test "load from events" do
    aggregate = ExampleAggregate.load("uuid", [ %ExampleAggregate.Events.NameAssigned{name: "Ben"} ])

    assert aggregate.state == %ExampleAggregate.State{name: "Ben"}
    assert aggregate.uuid == "uuid"
    assert aggregate.version == 1
    assert length(aggregate.pending_events) == 0  # pending events should be empty after replaying events
  end
end

