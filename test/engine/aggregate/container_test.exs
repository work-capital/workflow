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



  test "append events from an aggregate" do
    uuid = "aggregate-001-" <> UUID.uuid4
    aggregate = ExampleAggregate.new(uuid, 10)
      |> ExampleAggregate.assign_name("Ben")
      |> ExampleAggregate.assign_tel("66634234")

    res = Container.append_events_snapshot(aggregate)
    tes = %Engine.Aggregate.ContainerTest.ExampleAggregate{
            counter: 2,
            pending_events: [], 
            snapshot_period: 10,
            state: %Engine.Aggregate.ContainerTest.ExampleAggregate.State{name: "Ben", tel: "66634234"},
            uuid: uuid,
            version: 2}
    assert res == tes

  end

  # test "append events from container" do
  #   uuid = "container-002-" <> UUID.uuid4
  #   aggregate = ExampleAggregate.new(uuid, 2)
  #     |> ExampleAggregate.assign_name("Ben")
  #     |> ExampleAggregate.assign_tel("2342342")
  #   # inject the aggregate in the container
  #   container = %Container{uuid: uuid, module: ExampleAggregate, aggregate: aggregate}
  #   # append events
  #   assert {:ok, [0,1]} == Container.append_events(container)
  # end
  #
  # test "append snapshots from an aggregate" do
  #   uuid = "aggregate-003" <> UUID.uuid4
  #   aggregate = ExampleAggregate.new(uuid, 2)
  #     |> ExampleAggregate.assign_name("Ben")
  #     |> ExampleAggregate.assign_tel("2342342")
  #   # inject the aggregate in the container
  #   container = %Container{uuid: uuid, module: ExampleAggregate, aggregate: aggregate}
  #   # append events
  #   assert {:ok, [0,1]} == Container.append_events(container)
  #   # append snapshots
  #   assert {:ok, [0,0]} == Container.append_snapshot(container)   # two events, so snapshot it
  # end
  #
  # test "rebuild a container from scratch" do
  #   uuid = "container-004-" <> UUID.uuid4
  #   aggregate = ExampleAggregate.new(uuid, 2)
  #     |> ExampleAggregate.assign_name("Ben")
  #     |> ExampleAggregate.assign_tel("2342342")
  #   # inject the aggregate in the container
  #   container = %Container{uuid: uuid, module: ExampleAggregate, aggregate: aggregate}
  #   # append events
  #   assert {:ok, [0,1]} == Container.append_events(container)
  #
  #   # new empty container
  #   container2 = %Container{uuid: uuid, module: ExampleAggregate, snapshot_period: 8}
  #   res = Container.rebuild_from_events(container2)
  #   assert res ==
  #     %Engine.Aggregate.Container{aggregate: %Engine.Aggregate.ContainerTest.ExampleAggregate{
  #     counter: 2,
  #     pending_events: [],
  #     snapshot_period: 8,
  #     state: %Engine.Aggregate.ContainerTest.ExampleAggregate.State{name: "Ben", tel: "2342342"},
  #                                                                   uuid: uuid, version: 2}, 
  #     module: Engine.Aggregate.ContainerTest.ExampleAggregate,
  #     snapshot_period: 8,
  #     uuid: uuid}
  #
  # end
  #
  # test "rebuild a container from a snapshot and replay events from there" do
  #   uuid = "container-005-" <> UUID.uuid4
  #   write = fn(aggregate, uuid) -> 
  #     %Container{uuid: uuid, module: ExampleAggregate, aggregate: aggregate}
  #       |> Container.append_events_snapshot
  #   end
  #   agg1  = ExampleAggregate.new(uuid, 2)
  #   agg2  = agg1 |> ExampleAggregate.assign_name("Ben")
  #   agg3  = agg2 |> ExampleAggregate.assign_name("Ben")
  #   agg4  = agg3 |> ExampleAggregate.assign_name("Ben")
  #   agg5  = agg4 |> ExampleAggregate.assign_name("Ben")
  #   agg6  = agg5 |> ExampleAggregate.assign_name("Ben")
  #
  #     write.(agg1, uuid)
  #     write.(agg2, uuid)
  #     write.(agg3, uuid)
  #     write.(agg4, uuid)
  #     write.(agg5, uuid)
  #     write.(agg6, uuid)
      # |> ExampleAggregate.assign_tel("1")
      # |> ExampleAggregate.assign_name("Bon")
      # |> ExampleAggregate.assign_tel("2")
      # |> ExampleAggregate.assign_name("Ban")
      # |> ExampleAggregate.assign_tel("3")
      # |> ExampleAggregate.assign_name("Bin")
      # |> ExampleAggregate.assign_tel("4")
      # |> ExampleAggregate.assign_name("Ben")
      # |> ExampleAggregate.assign_tel("1")
      # |> ExampleAggregate.assign_name("Bon")
      # |> ExampleAggregate.assign_tel("2")
      # |> ExampleAggregate.assign_name("Ban")
      # |> ExampleAggregate.assign_tel("3")
      # |> ExampleAggregate.assign_name("Bin")
      # |> ExampleAggregate.assign_tel("4")
    # inject the aggregate in the container
    # container = %Container{uuid: uuid, module: ExampleAggregate, aggregate: aggregate}
    # IO.inspect container.aggregate
    # # append events
    # assert {:ok, [0,7]} == Container.append_events_snapshot(container)

    # new empty container
    # container2 = %Container{uuid: uuid, module: ExampleAggregate, snapshot_period: 8}
    # res = Container.rebuild_from_events(container2)
    # assert res ==
    #   %Engine.Aggregate.Container{aggregate: %Engine.Aggregate.ContainerTest.ExampleAggregate{
    #   counter: 2,
    #   pending_events: [],
    #   snapshot_period: 8,
    #   state: %Engine.Aggregate.ContainerTest.ExampleAggregate.State{name: "Ben", tel: "2342342"},
    #                                                                 uuid: uuid, version: 2}, 
    #   module: Engine.Aggregate.ContainerTest.ExampleAggregate,
    #   snapshot_period: 8,
    #   uuid: uuid}
    # end

  def write(aggregate, uuid), do:
    %Container{uuid: uuid, module: ExampleAggregate, aggregate: aggregate}
      |> Container.append_events_snapshot


  # test "rehydrate from container" do
  #   uuid = "container-003-" <> UUID.uuid4
  #   aggregate = ExampleAggregate.new(uuid, 2)
  #     |> ExampleAggregate.assign_name("Ben")
  #     |> ExampleAggregate.assign_tel("2342342")
  #   # inject the aggregate in the container
  #   container = %Container{uuid: uuid, module: ExampleAggregate, aggregate: aggregate}
  #   # append events
  #   assert {:ok, [0,1]} == Container.append_events(container)
  #   # append snapshots
  #   assert {:ok, [0,0]} == Container.append_snapshot(container)   # two events, so snapshot it
  #
  #   # add one event more in the aggregate above, and watch snapshot postponed
  #   aggregate = aggregate |> ExampleAggregate.assign_tel("987987987")
  #   container = %Container{uuid: uuid, module: ExampleAggregate, aggregate: aggregate}
  #   {:ok, :postponed} = Container.append_snapshot(container) # three events doesn't snapshot
  #
  #   # load events and compare with the appended ones
  #   #IO.inspect container
  #   events = Container.load_all_events(container)
  #   res = {:ok, [%Engine.Aggregate.ContainerTest.ExampleAggregate.Events.NameAssigned{name: "Ben"},
  #                %Engine.Aggregate.ContainerTest.ExampleAggregate.Events.TelAssigned{tel: "2342342"}]}
  #   assert events == res
  #
  #   # rehydratate from an uuid
  #   # agg = ExampleAggregate.new(uuid)
  #   # con = %Container{uuid: uuid, module: ExampleAggregate, aggregate: agg}
  #   # res = Container.rehydrate(con)
  #   # IO.inspect res
  # end




end

