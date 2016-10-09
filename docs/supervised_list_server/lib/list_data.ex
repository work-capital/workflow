defmodule ListData do
  use GenServer.Behaviour

  # Public API
  def start_link do
    :gen_server.start_link(__MODULE__, [], [])
  end

  def save_state(pid, state) do
    :gen_server.cast pid, {:save_state, state}
  end

  def get_state(pid) do
    :gen_server.call pid, :get_state
  end

  # GenServer API
  def init(list) do
    {:ok, list}
  end

  def handle_call(:get_state, _from, current_state) do
    {:reply, current_state, current_state}
  end

  def handle_cast({:save_state, new_state}, _current_state) do
    {:noreply, new_state}
  end
end
