defmodule AggregateSupervisor do
  @moduledoc """
  Instead of using the standard Supervisor to supervise our aggregates, we use this one
  that already includes the new() to create new childs. Why it's important ? because
  this new() function is called from the repository to create zero ready to use pids.
  """


  defmacro __using__(_) do
    quote do
    use Supervisor
    def start_link(), do:
      Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)


    def new(), do:
      Supervisor.start_child(__MODULE__, [])  # [] is sent to call back start_link() in gen_aggreg
    end
  end

end


