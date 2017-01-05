defmodule Workflow.Snapshotter do
  @moduledoc """
  Receives an async message with the state to store snapshots.
  """
  use GenServer

  ### Api

  @doc "Starts the snapshotter"
  def start_link, do:
    GenServer.start_link(__MODULE__, :ok, [])

  @doc "Append snapshot"
  def send_snapshot(server, state), do:
    GenServer.cast(server, {:state, state})

  ### Server Callbacks

  def init(:ok), do:
    {:ok, %{}}

  def handle_cast({:state, state}, _from, names), do:
    {:reply, state}

  @doc """
  Auto snapshot algorithm. Always snapshot the first existing state, and returns true when the event 
  counter C arrives at the specific position. 
  """
  def check_snapshot(counter, position), do: mod(counter, position)

  defp mod(0,p),             do: true    # we snapshot the state from the first event
  defp mod(c,p) when c  < p, do: false
  defp mod(c,p) when c >= p  do
    case rem c,p do
      0 -> true
      _ -> false
    end
  end

end
