defmodule Engine.Aggregate.SupervisorTest do
  #doctest Engine.Aggregate.Server
  #use Engine.StorageCase
  use ExUnit.Case


  alias Engine.Aggregate

  test "start server" do
    id      = UUID.uuid4
    {:ok, pid} = GenServer.start_link(Engine.Aggregate.Server,
                                     %Engine.Container{ module: Engine.Example.Account, uuid: "234"})
    {:ok, pid2} = Aggregate.Server.start_link(Engine.Example.Account, "234")
  end


  test "supervisor start and stop" do
    restart()

    # count 
    sup_pid = Process.whereis(Engine.Aggregate.Supervisor)
    count   = Supervisor.count_children(sup_pid)
    assert count == %{active: 0, specs: 1, supervisors: 0, workers: 0}

    # create new worker
    id      = UUID.uuid4
    {:ok, e} = Supervisor.start_child(Engine.Aggregate.Supervisor, [Engine.Example.Account, id])

    # count again
    count2   = Supervisor.count_children(sup_pid)
    assert count2 == %{active: 1, specs: 1, supervisors: 0, workers: 1}
  end


  def restart() do
    Application.stop(:engine)
    Application.start(:engine)
  end

end
