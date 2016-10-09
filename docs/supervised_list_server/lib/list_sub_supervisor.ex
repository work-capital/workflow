defmodule ListSubSupervisor do
  use Supervisor.Behaviour

  def start_link(list_data_pid) do
    :supervisor.start_link(__MODULE__, list_data_pid)
  end

  def init(list_data_pid) do
    child_processes = [worker(ListServer, [list_data_pid])]
    supervise child_processes, strategy: :one_for_one
  end
end
