defmodule Workflow.Adapter.Extreme.Router do
  require Logger
  use GenServer

  # def start_link(extreme, last_processed_event), do: 
  #   GenServer.start_link(__MODULE__, {extreme, last_processed_event})

  def start_link(:ok, extreme), do:
    GenServer.start_link(__MODULE__, {:ok, extreme}, [name: Workflow.Router])

  def init({:ok, extreme}) do
    stream = "storage-test-02-660c072d-c726-4a25-8e09-26b628bfb7af"
    stream2 = "$cd-persistence"
    state = %{ event_store: extreme, stream: stream, last_event: 5 }
    GenServer.cast(self, :subscribe)
    {:ok, state}
  end

  # def init({extreme, last_processed_event}) do
  #   stream = "people"
  #   state = %{ event_store: extreme, stream: stream, last_event: last_processed_event }
  #   GenServer.cast self, :subscribe
  #   {:ok, state}
  # end
  def handle_cast(:subscribe, state) do
    IO.inspect "hi from subscribe"
    # read only unprocessed events and stay subscribed
    # {:ok, subscription} = 
    #     Extreme.read_and_stay_subscribed(state.event_store, self, state.stream, state.last_event + 1)
    {:ok, subscription} = 
        Extreme.subscribe_to(state.event_store, self, "$ce-persistence")
    # we want to monitor when subscription is crashed so we can resubscribe
    {:noreply, state}
    # ref = Process.monitor subscription
    # {:noreply, %{state | subscription_ref: ref}}
  end

  # def handle_info({:DOWN, ref, :process, _pid, _reason}, %{subscription_ref: ref} = state) do
  #   GenServer.cast(self, :subscribe)
  #   {:noreply, state}
  # end

  def handle_info({:on_event, push}, state) do
    push.event.data
    |> process_event
    event_number = push.link.event_number
    :ok = update_last_event state.stream, event_number
    {:noreply, %{state|last_event: event_number}}
  end

  def handle_info(:caught_up, state) do
    Logger.debug "We are up to date!"
    {:noreply, state}
  end
  def handle_info(_msg, state), do: {:noreply, state}

  defp process_event(event), do: IO.puts("Do something with #{inspect event}")
  defp update_last_event(_stream, _event_number), do: 
    IO.puts("Persist last processed event_number for stream")
end






















# defmodule Workflow.Router do
#   use Extreme.Listener
#
#   # returns last processed event by MyListener on stream_name, -1 if none has been processed so far
#   defp get_last_event(stream_name), do: 
#     -1
#     #IO.inspect(stream_name)
#     #DB.get_last_event MyListener, stream_name
#
#   defp process_push(push, stream_name) do
#     #for indexed stream we need to follow push.link.event_number, otherwise push.event.event_number
#     #event_number = push.link.event_number
#     # DB.in_transaction fn ->
#     #   Logger.info "Do some processing of event #{inspect push.event.event_type}"
#     #   :ok = push.event.data
#     #          |> :erlang.binary_to_term
#     #          |> process_event(push.event.event_type)
#     #   DB.ack_event(MyListener, stream_name, event_number)  
#     # end
#     {:ok, 3}
#   end
#
#   # This override is optional
#   defp caught_up, do: Logger.debug("We are up to date. YEEEY!!!")
#
#   def process_event(data, "Elixir.MyApp.Events.PersonCreated") do
#     Logger.debug "Doing something with #{inspect data}"
#     :ok
#   end
#   def process_event(_, _), do: :ok # Just acknowledge events we are not interested in
# end
#
