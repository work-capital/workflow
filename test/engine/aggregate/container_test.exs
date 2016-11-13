defmodule Engine.Aggregate.ContainerTest do
  use ExUnit.Case
  alias Engine.Aggregate.Container
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
  test "append events and make snaphot from container" do
    uuid = "container-" <> UUID.uuid4
    aggregate = ExampleAggregate.new(uuid)
      |> ExampleAggregate.assign_name("Ben")
      |> ExampleAggregate.assign_tel("66634234")

    # inject the aggregate in the container
    container = %Container{uuid: uuid, module: ExampleAggregate, aggregate: aggregate}
    {:ok, [0,1]} = Container.append_events(container)

    IO.inspect container
    #res = Container.append_snapshot(container)
  end


  test "applies event" do
    uuid = "container-" <> UUID.uuid4
    aggregate =
      ExampleAggregate.new("uuid")
      |> ExampleAggregate.assign_name("Ben")
      |> ExampleAggregate.assign_tel("66634234")

    container = %Container{module: ExampleAggregate, uuid: uuid, aggregate: aggregate}
    IO.inspect container
  end




end

