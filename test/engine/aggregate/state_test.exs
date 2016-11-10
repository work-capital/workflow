defmodule Engine.Aggregate.StateTest do
  use ExUnit.Case
  alias Engine.Aggregate.State
  #doctest EventSourced.Aggregate

  defmodule ExampleAggregate do
    use Engine.Aggregate.Aggregate, fields: [name: "", tel: ""]

    defmodule Events.NameAssigned, do: defstruct name: ""
    defmodule Events.TelAssigned,  do: defstruct tel: ""

    def assign_name(%ExampleAggregate{} = aggregate, name), do:
      aggregate
      |> update(%Events.NameAssigned{name: name})

    def assign_tel(%ExampleAggregate{} = aggregate, tel), do:
      aggregate
      |> update(%Events.TelAssigned{tel: tel})


    def apply(%ExampleAggregate.State{} = state, %Events.NameAssigned{} = event),
      do: %ExampleAggregate.State{state | name: event.name }

    def apply(%ExampleAggregate.State{} = state, %Events.TelAssigned{} = event),
      do: %ExampleAggregate.State{state | tel: event.tel }

  end


  test "applies event" do
    aggregate =
      ExampleAggregate.new("uuid")
      |> ExampleAggregate.assign_name("Ben")
      |> ExampleAggregate.assign_tel("66634234")

    state = %State{module: ExampleAggregate, uuid: "ID-123", aggregate: aggregate}
    {:ok, position} = State.append_events(state)
    IO.inspect position

    assert aggregate.state == %ExampleAggregate.State{name: "Ben", tel: "66634234"}
    assert aggregate.uuid == "uuid"
    assert aggregate.version == 2
    assert length(aggregate.pending_events) == 2
  end

  test "load from events, given an uuid" do
    aggregate = ExampleAggregate.load("uuid", [
      %ExampleAggregate.Events.NameAssigned{name: "Ben"},
      %ExampleAggregate.Events.TelAssigned{tel: "66634234"}])

    assert aggregate.state == %ExampleAggregate.State{name: "Ben", tel: "66634234"}
    assert aggregate.uuid == "uuid"
    assert aggregate.version == 2
    # pending events should be empty after replaying events
    assert length(aggregate.pending_events) == 0
  end

  test "load from events from a snapshot point" do
    aggregate =
      ExampleAggregate.new("uuid")
      |> ExampleAggregate.assign_name("Ben")
      |> ExampleAggregate.load([
              %ExampleAggregate.Events.NameAssigned{name: "Bon"},
              %ExampleAggregate.Events.TelAssigned{tel: "66634234"}])
      |> ExampleAggregate.assign_name("Jim")

    assert aggregate.state == %ExampleAggregate.State{name: "Jim", tel: "66634234"}
    assert aggregate.uuid == "uuid"
    assert aggregate.version == 3
    assert length(aggregate.pending_events) == 1
  end



end

