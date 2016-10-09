defmodule Account.Aggregate do
  @moduledoc """
  Flow:  API -> HANDLE_EXEC -> APPLY EVENT
  To build your aggregate, use the API to send commands to the main macro, use handle_exec to
  catch this commands [by the gen_server] and create a new event from this command, and use
  apply_event to catch the new created events and change the state of you aggregate.
  """
  use GenAggregate
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
  def create(pid, id), do:
    exec(pid, {:create, id})

  def deposit(pid, amount), do:
    exec(pid, {:deposit, amount})

  def withdraw(pid, amount), do:
    exec(pid, {:withdraw, amount})

  def init(:start), do:
    {:ok, %{%State{} | balance: 0, event_counter: 0, changes: []}}

  ## COMMAND HANDLERS [create here your Event]
  def handle_exec({:create, id}, from, state), do:
    %{%AccountCreated{} | id: id, date_created: now}

  def handle_exec({:deposit, amount}, from, state) do
    new_balance = state.balance + amount
    %{%MoneyDeposited{} | id: state.id, amount: amount, new_balance: new_balance,
                          transaction_date: now}
  end

  def handle_exec({:withdraw, amount}, from, state) do
    new_balance = state.balance - amount
    case new_balance < 0 do
      false ->  %{%MoneyWithdrawn{} | id: state.id,             amount: amount, 
                                      new_balance: new_balance, transaction_date: now}
      true  ->  %{%PaymentDeclined{} | id: state.id, amount: amount, transaction_date: now}
    end
  end

  # HELPER FUNCTIONS
  defp now, do:
  	Calendar.DateTime.now_utc |> Calendar.DateTime.Format.iso8601

  # APPLY EVENTS  [apply your new created event to this aggregate's state]
  def apply_event(event = %AccountCreated{}, state) do
    Repository.add_to_cache(event.id, self)    # --> note that when created we add to repository cache.
    %{state | id: event.id, date_created: event.date_created}
  end

  def apply_event(event = %MoneyDeposited{}, state) do
    new_balance = state.balance + event.amount
    %{state | balance: new_balance}
  end

  def apply_event(event = %MoneyWithdrawn{}, state) do
    new_balance = state.balance - event.amount
    %{state | balance: new_balance}
  end

  def apply_event(event = %PaymentDeclined{}, state) do
    state
  end


end
