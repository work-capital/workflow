defmodule ListServer do
  use GenServer.Behaviour

  ### Public API
  def start_link(list_data_pid) do
    :gen_server.start_link({:local, :list}, __MODULE__, list_data_pid, [])
  end

  def clear do
    :gen_server.cast :list, :clear
  end

  def add(item) do
    :gen_server.cast :list, {:add, item}
  end

  def remove(item) do
    :gen_server.cast :list, {:remove, item}
  end

  def items do
    :gen_server.call :list, :items
  end

  def crash do
    :gen_server.cast :list, :crash
  end

  ### GenServer API
  def init(list_data_pid) do
    list = ListData.get_state(list_data_pid)
    {:ok, {list, list_data_pid}}
  end

  # Clear the list
  def handle_cast(:clear, {_list, list_data_pid}) do
    {:noreply, {[], list_data_pid}}
  end
  def handle_cast({:add, item}, {list, list_data_pid}) do
    {:noreply, {list ++ [item], list_data_pid}}
  end
  def handle_cast({:remove, item}, {list, list_data_pid}) do
    {:noreply, {List.delete(list, item), list_data_pid}}
  end
  def handle_cast(:crash, _state) do
    1 = 2
  end

  def handle_call(:items, _from, {list, list_data_pid}) do
    {:reply, list, {list, list_data_pid}}
  end

  # Handle termination
  def terminate(_reason, {list, list_data_pid}) do
    ListData.save_state list_data_pid, list
  end
end
