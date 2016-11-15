defmodule Engine.PersistenceTest do
  use ExUnit.Case
  alias Engine.Aggregate.Persistence
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



  # test "append events from an aggregate" do
  #   uuid = "aggregate-001-" <> UUID.uuid4
  #   aggregate = ExampleAggregate.new(uuid, 10)
  #     |> ExampleAggregate.assign_name("Ben")
  #     |> ExampleAggregate.assign_tel("66634234")
  #
  #   res = Persistence.append_events(aggregate)
  #   tes = %Engine.Aggregate.PersistenceTest.ExampleAggregate{
  #           state: %Engine.Aggregate.PersistenceTest.ExampleAggregate.State{name: "Ben", tel: "66634234"},
  #           counter: 2, pending_events: [],
  #           snapshot_period: 10,
  #           uuid: uuid, version: 2}
  #   assert res == tes
  # end
  #
  # test "append snapshots from an aggregate" do
  #   uuid = "aggregate-002-" <> UUID.uuid4
  #   aggregate = ExampleAggregate.new(uuid, 10)
  #     |> ExampleAggregate.assign_name("Ben")
  #     |> ExampleAggregate.assign_tel("66634234")
  #
  #   res = Persistence.append_snapshot(aggregate)
  #   tes = %Engine.Aggregate.PersistenceTest.ExampleAggregate{counter: 2, pending_events:
  #            [%Engine.Aggregate.PersistenceTest.ExampleAggregate.Events.NameAssigned{name: "Ben"},
  #             %Engine.Aggregate.PersistenceTest.ExampleAggregate.Events.TelAssigned{tel: "66634234"}],
  #          snapshot_period: 10,
  #          state: %Engine.Aggregate.PersistenceTest.ExampleAggregate.State{name: "Ben", tel: "66634234"}, 
  #          uuid: uuid,
  #          version: 2}
  #   assert res == tes
  # end
  #
  # test "append snapshots and events in one shot" do
  #   uuid = "aggregate-003-" <> UUID.uuid4
  #   aggregate = ExampleAggregate.new(uuid, 2)
  #     |> ExampleAggregate.assign_name("Ben")
  #     |> Persistence.append_events_snapshot
  #     |> ExampleAggregate.assign_tel("1")
  #     |> Persistence.append_events_snapshot
  #     |> ExampleAggregate.assign_name("Bon")
  #     |> Persistence.append_events_snapshot
  #     |> ExampleAggregate.assign_tel("2")
  #     |> Persistence.append_events_snapshot
  #     |> ExampleAggregate.assign_name("Bin")
  #     |> Persistence.append_events_snapshot
  #     |> ExampleAggregate.assign_tel("3")
  #     |> Persistence.append_events_snapshot
  #
  #   tes = %Engine.Aggregate.PersistenceTest.ExampleAggregate{counter: 6, 
  #            pending_events: [],
  #            snapshot_period: 2,
  #            state: %Engine.Aggregate.PersistenceTest.ExampleAggregate.State{name: "Bin", tel: "3"}, 
  #            uuid: uuid,
  #            version: 6}
  #   assert aggregate == tes
  # end
  #
  # #TODO: rebuild from events
  # test "rebuild from events" do
  #   uuid = "aggregate-005-" <> UUID.uuid4
  #   aggregate = ExampleAggregate.new(uuid, 2)
  #     |> ExampleAggregate.assign_name("Ben")
  #     |> Persistence.append_events_snapshot
  #     |> ExampleAggregate.assign_tel("1")
  #     |> Persistence.append_events_snapshot
  #     |> ExampleAggregate.assign_name("Bon")
  #     |> Persistence.append_events_snapshot
  #     |> ExampleAggregate.assign_tel("2")
  #     |> Persistence.append_events_snapshot
  #
  #     aggregate2 = Persistence.replay_from_events(ExampleAggregate, uuid, 2)
  #     #IO.inspect aggregate2
  #     tes = %Engine.Aggregate.PersistenceTest.ExampleAggregate{counter: 4, pending_events: [],
  #             snapshot_period: 40,
  #             state: %Engine.Aggregate.PersistenceTest.ExampleAggregate.State{name: "Bon", tel: "2"},
  #             uuid: uuid,
  #             version: 4}
  #     assert aggregate2 == tes
  # end
  #
  # test "rebuild from snapshot, replaying events from the last counter position" do
  #   uuid = "aggregate-006-" <> UUID.uuid4
  #   aggregate = ExampleAggregate.new(uuid, 3)
  #     |> ExampleAggregate.assign_name("Ben")
  #     |> Persistence.append_events_snapshot
  #     |> ExampleAggregate.assign_tel("1")
  #     |> Persistence.append_events_snapshot
  #     |> ExampleAggregate.assign_name("Bon")
  #     |> Persistence.append_events_snapshot
  #     |> ExampleAggregate.assign_tel("2")
  #     |> Persistence.append_events_snapshot
  #     |> ExampleAggregate.assign_name("Den")
  #     |> Persistence.append_events_snapshot
  #     |> ExampleAggregate.assign_tel("3")         # ----> last snapshot here !!!
  #     |> Persistence.append_events_snapshot
  #     |> ExampleAggregate.assign_name("Don")
  #     |> Persistence.append_events_snapshot
  #     |> ExampleAggregate.assign_tel("4")
  #     |> Persistence.append_events_snapshot
  #
  #
  #
  #     #### PIPELINE RESULT
  #     last = %Engine.Aggregate.PersistenceTest.ExampleAggregate{counter: 8, pending_events: [],
  #         snapshot_period: 3,
  #         state: %Engine.Aggregate.PersistenceTest.ExampleAggregate.State{name: "Don",tel: "4"},
  #         uuid: uuid, version: 8}
  #     assert aggregate == last
  #     # IO.inspect aggregate
  #
  #     #### LOAD SNAPSHOT
  #     snapshot = Persistence.load_snapshot(ExampleAggregate, uuid)   # state: 
  #     snap_res = %Engine.Aggregate.PersistenceTest.ExampleAggregate{counter: 6, pending_events: [],
  #         snapshot_period: 3,
  #         state: %Engine.Aggregate.PersistenceTest.ExampleAggregate.State{name: "Den", tel: "3"},
  #         uuid: uuid,version: 6}
  #     assert snapshot = snap_res
  #     # IO.inspect snapshot
  #
  #     #### REPLAY FROM SNAPSHOT
  #     rebuilt     = Persistence.replay_from_snapshot(snapshot, ExampleAggregate)
  #     rebuilt_res = %Engine.Aggregate.PersistenceTest.ExampleAggregate{counter: 8, pending_events: [],
  #       snapshot_period: 3, 
  #       state: %Engine.Aggregate.PersistenceTest.ExampleAggregate.State{name: "Don", tel: "4"},
  #       uuid: uuid, version: 2}
  #     assert rebuilt = rebuilt_res
  #     # IO.inspect rebuilt
  #
  #     rehydrate     = Persistence.rehydrate(ExampleAggregate, uuid)
  #     rehydrate_res = %Engine.Aggregate.PersistenceTest.ExampleAggregate{counter: 8, pending_events: [],
  #       snapshot_period: 3,
  #       state: %Engine.Aggregate.PersistenceTest.ExampleAggregate.State{name: "Don", tel: "4"},
  #       uuid: uuid, version: 2}
  #     assert rehydrate = rehydrate_res
  #     #IO.inspect rehydrate
  # end
  #
  # #TODO: rebuild from events causing error, and starting from zero
  # # test "append events from container" do
  # #   uuid = "container-002-" <> UUID.uuid4
  # #   aggregate = ExampleAggregate.new(uuid, 2)
  # #     |> ExampleAggregate.assign_name("Ben")
  # #     |> ExampleAggregate.assign_tel("2342342")
  # #   # inject the aggregate in the container
  # #   container = %Persistence{uuid: uuid, module: ExampleAggregate, aggregate: aggregate}
  # #   # append events
  # #   assert {:ok, [0,1]} == Persistence.append_events(container)
  # # end
  # #
  #
  # def write(aggregate, uuid), do:
  #   %Persistence{uuid: uuid, module: ExampleAggregate, aggregate: aggregate}
  #     |> Persistence.append_events_snapshot

end

