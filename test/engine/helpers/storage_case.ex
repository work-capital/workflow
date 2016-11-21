defmodule Engine.StorageCase do
  use ExUnit.CaseTemplate

  setup do
    Application.stop(:engine)
    #Application.stop(:eventstore)

    reset_storage

    Application.ensure_all_started(:engine)
    :ok
  end

  defp reset_storage do
    #storage_config = Application.get_env(:eventstore, EventStore.Storage)

    #{:ok, conn} = Postgrex.start_link(storage_config)

    #EventStore.Storage.Initializer.reset!(conn)
  end
end
