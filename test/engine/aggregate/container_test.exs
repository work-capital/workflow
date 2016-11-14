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

    res = Container.append_events(aggregate)
    tes = %Engine.Aggregate.ContainerTest.ExampleAggregate{
            counter: 2,
            pending_events: [],
            snapshot_period: 10,
            state: %Engine.Aggregate.ContainerTest.ExampleAggregate.State{name: "Ben", tel: "66634234"},
            uuid: uuid,
            version: 2}
    assert res == tes
  end

  test "append snapshots from an aggregate" do
    uuid = "aggregate-002-" <> UUID.uuid4
    aggregate = ExampleAggregate.new(uuid, 10)
      |> ExampleAggregate.assign_name("Ben")
      |> ExampleAggregate.assign_tel("66634234")

    res = Container.append_snapshot(aggregate)
    tes = %Engine.Aggregate.ContainerTest.ExampleAggregate{counter: 2, pending_events:
             [%Engine.Aggregate.ContainerTest.ExampleAggregate.Events.NameAssigned{name: "Ben"},
              %Engine.Aggregate.ContainerTest.ExampleAggregate.Events.TelAssigned{tel: "66634234"}],
           snapshot_period: 10,
           state: %Engine.Aggregate.ContainerTest.ExampleAggregate.State{name: "Ben", tel: "66634234"}, 
           uuid: uuid,
           version: 2}
    assert res == tes
  end

  test "append snapshots and events in one shot" do
    uuid = "aggregate-003-" <> UUID.uuid4
    aggregate = ExampleAggregate.new(uuid, 2)
      |> ExampleAggregate.assign_name("Ben")
      |> Container.append_events_snapshot
      |> ExampleAggregate.assign_tel("1")
      |> Container.append_events_snapshot
      |> ExampleAggregate.assign_name("Bon")
      |> Container.append_events_snapshot
      |> ExampleAggregate.assign_tel("2")
      |> Container.append_events_snapshot
      |> ExampleAggregate.assign_name("Bin")
      |> Container.append_events_snapshot
      |> ExampleAggregate.assign_tel("3")
      |> Container.append_events_snapshot

    tes = %Engine.Aggregate.ContainerTest.ExampleAggregate{counter: 6, 
             pending_events: [],
             snapshot_period: 2,
             state: %Engine.Aggregate.ContainerTest.ExampleAggregate.State{name: "Bin", tel: "3"}, 
             uuid: uuid,
             version: 6}
    assert aggregate == tes
  end

  #TODO: rebuild from events
  test "rebuild from events" do
    uuid = "aggregate-005-" <> UUID.uuid4
    aggregate = ExampleAggregate.new(uuid, 2)
      |> ExampleAggregate.assign_name("Ben")
      |> Container.append_events_snapshot
      |> ExampleAggregate.assign_tel("1")
      |> Container.append_events_snapshot
      |> ExampleAggregate.assign_name("Bon")
      |> Container.append_events_snapshot
      |> ExampleAggregate.assign_tel("2")
      |> Container.append_events_snapshot

      aggregate2 = Container.replay_from_events(ExampleAggregate, uuid, 2)
      #IO.inspect aggregate2
      tes = %Engine.Aggregate.ContainerTest.ExampleAggregate{counter: 4, pending_events: [],
              snapshot_period: 40,
              state: %Engine.Aggregate.ContainerTest.ExampleAggregate.State{name: "Bon", tel: "2"},
              uuid: uuid,
              version: 4}
      assert aggregate2 == tes
  end

  test "rebuild from snapshot, replaying events from the last counter position" do
    uuid = "aggregate-006-" <> UUID.uuid4
    aggregate = ExampleAggregate.new(uuid, 3)
      |> ExampleAggregate.assign_name("Ben")
      |> Container.append_events_snapshot
      |> ExampleAggregate.assign_tel("1")
      |> Container.append_events_snapshot
      |> ExampleAggregate.assign_name("Bon")
      |> Container.append_events_snapshot
      |> ExampleAggregate.assign_tel("2")
      |> Container.append_events_snapshot
      |> ExampleAggregate.assign_name("Den")
      |> Container.append_events_snapshot
      |> ExampleAggregate.assign_tel("3")         # ----> last snapshot here !!!
      |> Container.append_events_snapshot
      |> ExampleAggregate.assign_name("Don")
      |> Container.append_events_snapshot
      |> ExampleAggregate.assign_tel("4")
      |> Container.append_events_snapshot



      #### PIPELINE RESULT
      last = %Engine.Aggregate.ContainerTest.ExampleAggregate{counter: 8, pending_events: [],
          snapshot_period: 3,
          state: %Engine.Aggregate.ContainerTest.ExampleAggregate.State{name: "Don",tel: "4"},
          uuid: uuid, version: 8}
      assert aggregate == last
      # IO.inspect aggregate

      #### LOAD SNAPSHOT
      snapshot = Container.load_snapshot(ExampleAggregate, uuid)   # state: 
      snap_res = %Engine.Aggregate.ContainerTest.ExampleAggregate{counter: 6, pending_events: [],
          snapshot_period: 3,
          state: %Engine.Aggregate.ContainerTest.ExampleAggregate.State{name: "Den", tel: "3"},
          uuid: uuid,version: 6}
      assert snapshot = snap_res
      # IO.inspect snapshot

      #### REPLAY FROM SNAPSHOT
      rebuilt     = Container.replay_from_snapshot(snapshot, ExampleAggregate)
      rebuilt_res = %Engine.Aggregate.ContainerTest.ExampleAggregate{counter: 8, pending_events: [],
        snapshot_period: 3, 
        state: %Engine.Aggregate.ContainerTest.ExampleAggregate.State{name: "Don", tel: "4"},
        uuid: uuid, version: 2}
      assert rebuilt = rebuilt_res
      # IO.inspect rebuilt

      rehydrate     = Container.rehydrate(ExampleAggregate, uuid)
      rehydrate_res = %Engine.Aggregate.ContainerTest.ExampleAggregate{counter: 8, pending_events: [],
        snapshot_period: 3,
        state: %Engine.Aggregate.ContainerTest.ExampleAggregate.State{name: "Don", tel: "4"},
        uuid: uuid, version: 2}
      assert rehydrate = rehydrate_res
      #IO.inspect rehydrate
  end

  #TODO: rebuild from events causing error, and starting from zero
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

  def write(aggregate, uuid), do:
    %Container{uuid: uuid, module: ExampleAggregate, aggregate: aggregate}
      |> Container.append_events_snapshot

end

