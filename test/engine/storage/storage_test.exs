defmodule Engine.Storage.StorageTest do
  use ExUnit.Case
  require Logger
  alias Engine.Storage.EventStore

	defmodule PersonCreated, do: defstruct [:name]
  defmodule PersonChangedName, do: defstruct [:name]
  defmodule MyState, do: defstruct state: nil, event_counter: nil, changes: []


  alias Engine.Storage.Storage

	setup_all do
    Application.stop(:engine)
    :ok = Application.start(:engine)
  end


  test "test if storage can be read from config file using Settings helper" do
    # print the current storage (we can only supose what you want, so we only print)
    a = Storage.which_storage?()
    IO.inspect a

    # # setup the storage
    # Application.put_env(:engine, :storage, Postgres)
    # assert Postgres= Engine.Settings.get(:storage)
    #
    # Application.put_env(:engine, :storage, Eventstore)
    # assert Eventstore= Engine.Settings.get(:storage)
  end



end
