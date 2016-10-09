defmodule Account.Aggregate2 do
  @moduledoc """
  DRAFT to build the aggregate abstraction
  """
  use GenServer
  require Logger
  @module __MODULE__

  ## State
  alias Account.Model.State

  ## Events
  alias Account.Event.AccountCreated
  alias Account.Event.MoneyDeposited
  alias Account.Event.MoneyWithdrawn
  alias Account.Event.PaymentDeclined

  ## Repository
  alias Engine.Repository

  ## API
  def start_link(), do:                            # to start from supervisor
    GenServer.start_link(__MODULE__, :start, [])   # new process, without state

  def process_unsaved_changes(pid, saver), do:
    GenServer.call(pid, {:process_unsaved_changes, saver})

  def load_from_history(pid, events), do:
    GenServer.call(pid, {:load_from_history, events})

  def load_from_snapshot(pid, events, snapshot), do:
    GenServer.call(pid, {:load_from_snapshot, events, snapshot})

  def stop(pid), do:
    GenServer.cast(pid, :stop)

  def get_state(pid), do:
    GenServer.call(pid, :get_state)

  ## API
  def create(pid, id), do:
    GenServer.call(pid, {:attempt_command, {:create, id}})

  def deposit(pid, amount), do:
    GenServer.call(pid, {:attempt_command, {:deposit_money, amount}})

  def withdraw(pid, amount), do:
    GenServer.call(pid, {:attempt_command, {:withdraw_money, amount}})

  def init(:start), do:
    {:ok, %{%State{} | :balance => 0, :event_counter => 0,  :changes => []}}

  ##  CALLBACKS
  def handle_call({:apply_event, event}, from, state) do
    new_state = apply_event(event, state)
    {:reply, new_state, new_state}
  end

  def handle_call({:attempt_command, command}, from, state) do
    new_state = attempt_command(command, state)
    {:reply, new_state, new_state}
  end

  def handle_call({:process_unsaved_changes, saver} , from, state) do
    event_counter = saver.(state.id, state, :lists.reverse(state.changes))  # TODO: why list.reverse?
    new_state     = %{state | :changes => [], :event_counter => event_counter}
    {:reply, new_state, new_state}
  end

  def handle_call({:load_from_history, events}, from, state) do
    {:ok, initial_state} = init(:start)  # initial state from the beginig [after the caos!]
    new_state = apply_many_events(events, state = initial_state)
    {:reply, new_state, new_state}
  end

  def handle_call({:load_from_snapshot, events, snapshot}, from, state) do
    new_state = apply_many_events(events, state = snapshot) # initial state from snapshot
    {:reply, new_state, new_state}
  end

  def handle_call(:get_state, from, state), do:
    {:reply, state, state}

  def handle_cast(:stop, state), do:
    {:stop, :normal, state}

  # TODO: check if this code is necessary (I just paste from an example)
  def terminate(_reason, _state) do
    # is there  a race condition if the agent is
    # restarted too fast and it is registered ? 
    try do
      self() |> Process.info(:registered_name) |> elem(1) |> Process.unregister
    rescue
      _ -> :ok
    end
    :ok
  end

  def attempt_command({:create, id}, state) do
    event = %{%AccountCreated{} | :id => id, :date_created => now}
    apply_and_buffer_event(event, state)
  end

  def attempt_command({:deposit_money, amount}, state) do
    new_balance = state.balance + amount
    event = %{%MoneyDeposited{} | :id => state.id, :amount => amount, :new_balance => new_balance, :transaction_date => now}
    apply_and_buffer_event(event, state)
  end

  def attempt_command({:withdraw_money, amount}, state) do
    new_balance = state.balance - amount
    #IO.inspect(new_balance)
    event = case new_balance < 0 do
      false ->
        %{%MoneyWithdrawn{} | :id => state.id, :amount => amount, :new_balance => new_balance, :transaction_date => now}
      true ->
        %{%PaymentDeclined{} | :id => state.id, :amount => amount, :transaction_date => now}
    end
    apply_and_buffer_event(event, state)
  end

  def now, do:
    :calendar.local_time
    #Calendar.DateTime.now! "America/Sao_Paulo"


  def apply_event(event = %AccountCreated{}, state) do
    Repository.add_to_cache(event.id, self)
    new_state = %{state | :id => event.id, :date_created => event.date_created}
  end

  def apply_event(event = %MoneyDeposited{}, state) do
    new_balance = state.balance + event.amount
    new_state = %{state | :balance => new_balance}
  end

  def apply_event(event = %MoneyWithdrawn{}, state) do
    new_balance = state.balance - event.amount
    new_state = %{state | :balance => new_balance}
  end

  def apply_event(event = %PaymentDeclined{}, state) do
    state
  end



  ##  BUFFER [apply and buffer before append to stream]
  def apply_and_buffer_event(event, state) do
    new_state = apply_event(event, state)
    state_changes = Map.update(new_state, :changes, [], &[event|&1])
  end

  ## REPLAY
  def apply_many_events([], state),          do: state
  def apply_many_events([event|rest], state) do
    new_state1 = apply_event(event, state)
    counter    = new_state1.event_counter + 1  # simulate the event counter
    new_state2 = %{new_state1 | :event_counter => counter}
    apply_many_events(rest, new_state2)
  end

  ## COMMAND
  def attempt_command(_command, state) do
    Logger.error("attempt_command for unexpected command")
    state
  end
end
