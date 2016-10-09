defmodule GenAggregate do
  require Logger
  @moduledoc """
  We use Aggregate.new to make a new PID and set the starting point that state should be to begin
  applying events. Notice that we must simulate the event counting when replaying, because we
  need to know what is the next event to be saved in this stream stored on the state, in case we
  snapshot this state. Defcommand should have the event and apply only, and should generate 2 
  functions.

  defcommand create(id) do
    event = %{%AccountCreated{} | :id => id, :date_created => now}
    %{state | :id => event.id, :date_created => event.date_created}
  end

    TODO: add to repository cache automatically after replaying from eventstore
    TODO: should generate the following code:  (like Agent, Task, etc..)
    TODO: define if we want strict or tolerate behaviour (see https://hexdocs.pm/exactor)

  def create(pid, id), do:
    GenServer.call(pid, {:handle_exec, {:create, id}})

  def handle_exec({:create, id}, state) do
    event = %{%AccountCreated{} | :id => id, :date_created => now}               # create event
    new_state = %{state | :id => event.id, :date_created => event.date_created}  # apply
    state_changes = Map.update(new_state, :changes, [], &[event|&1])             # buffer
    #Repository.add_to_cache(event.id)
  end
  
  Reference on how to generate 2 function based on handle_exec:
  https://github.com/sasa1977/exactor/blob/master/lib/exactor/operations.ex 
  http://www.theerlangelist.com/article/macros_1
  https://github.com/burmajam/gen_aggregate/blob/master/lib/gen_aggregate.ex
  ## Example
  """

  defmacro __using__(_) do
    quote do
      require Logger
      use GenServer
      ##  API
      # TODO: start new pids using the Supervisor instead of directly starting
      # def new(), do:
      #   GenServer.start_link(__MODULE__, :start, [])   # new process, without state

      def start_link(), do:                            # to start from supervisor
        GenServer.start_link(__MODULE__, :start, [])   # new process, without state

      def exec(pid, cmd), do:                          # to be used by the client API
        GenServer.call(pid, {:cmd, cmd})

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

      ##  CALLBACKS
      def handle_call({:apply_event, event}, from, state) do
        new_state = apply_event(event, state)
        {:reply, new_state, new_state}
      end

      def handle_call({:cmd, command}, from, state) do
        event     = handle_exec(command, from, state)
        new_state = apply_and_buffer_event(event, state)
        {:reply, new_state, new_state}
      end

      def handle_call({:process_unsaved_changes, saver} , from, state) do
        event_counter = saver.(state.id, state, :lists.reverse(state.changes))  # TODO: why list.reverse?
        new_state     = %{state | changes: [], event_counter: event_counter}  # clean changes
        {:reply, new_state, new_state}                                              # after saving
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

      ##  BUFFER [apply and buffer before append to stream]
      def apply_and_buffer_event(event, state) do
        Logger.info "Apply and Buffer new Event: #{inspect event}"
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
      # def handle_exec(_command, state) do
      #   Logger.error("handle_exec for unexpected command")
      #   state
      # end
    end
  end
end
