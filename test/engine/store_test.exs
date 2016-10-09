defmodule EventStoreTest do
  use ExUnit.Case
  require Logger
  alias Engine.EventStore

	defmodule PersonCreated, do: defstruct [:name]
  defmodule PersonChangedName, do: defstruct [:name]
  defmodule MyState, do: defstruct state: nil, event_counter: nil, changes: []


	setup_all do
    Application.stop(:engine)
    :ok = Application.start(:engine)
  end

  test "save ONE event to eventstore" do
    id   = "test-1-" <> UUID.uuid4
    {:ok, position}   = EventStore.append_event(id ,%PersonCreated{name: "jim"})
    {:ok, position2}  = EventStore.append_event(id ,%PersonChangedName{name: "joe"})
    #IO.inspect message
    assert is_integer(position) == true

  end

  test "save MANY events to eventstore" do
    id   = "test-2-" <> UUID.uuid4
    # 10 events
    event_list = for n <- 1..10, do: %PersonCreated{name: n}
    # 3 events
    events = [ %PersonCreated{name: "jow"},
               %PersonCreated{name: "bow"},
               %PersonChangedName{name: "gue"}]
    {:ok, position} = EventStore.append_events(id, events)
    assert position == 2
    {:ok, position2} = EventStore.append_events(id, event_list)
    assert position2 == 12
  end


  test "read events from eventstore" do
    id   = "test-3-" <> UUID.uuid4
    EventStore.append_event(id, %PersonCreated{name: "jim"})
    {:ok, res} = EventStore.load_events(id)
    Logger.debug "Event Store Loaded Events: #{inspect res}"
    assert is_list(res) == true
  end

  # test "read events from eventstore from a specific position that does not exist" do
  #   id   = UUID.uuid4
  #   EventStore.append_event("people4",%PersonCreated{name: "jim"})
  #   {:ok, res} = eventStore.load_events("people4", 23423)
  #   IO.inspect res
  #   assert is_list(res) == true
  # end

  test "snapshot writing period, should be every 3 snapshots" do
    snapshot_period = 3
    id   = "test-4-" <> UUID.uuid4
    {:ok, res1 } = Engine.EventStore.append_snapshot(id,
                       %MyState{state: "hi", event_counter: 1}, snapshot_period)
    {:ok, res2 } = Engine.EventStore.append_snapshot(id,
                       %MyState{state: "hi", event_counter: 3}, snapshot_period)
    {:ok, res3 } = Engine.EventStore.append_snapshot(id,
                       %MyState{state: "hi", event_counter: 27}, snapshot_period)
    {:ok, res4 } = Engine.EventStore.append_snapshot(id,
                       %MyState{state: "hi", event_counter: 31}, snapshot_period)
    Logger.debug "Snapshot: #{inspect res3}"
    assert res1 == :postponed
    assert res2 != :postponed
    assert res3 != :postponed
    assert res4 == :postponed
  end


  test "test writing and reading several snapshots, and reading the last one" do
    # in 26 events, check if only 8 were written, once we jump every 3. The last should be 24
    snapshot_period = 3
    id   = "test-5-" <> UUID.uuid4
    for n <- 1..26, do:
      EventStore.append_snapshot(id,
                       %MyState{state: "good shape", event_counter: n},
                       snapshot_period)

    {:ok, res}   = EventStore.load_snapshot(id)
    assert res  == %MyState{state: "good shape", event_counter: 24}
  end

  test "write and try to read a non existing snapshot" do
    id   = "non-existent-in-database" <> UUID.uuid4
    {:error, res}  = EventStore.load_snapshot(id)
    assert res == :not_found
  end


end
