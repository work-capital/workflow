defmodule Engine.Repository do
  @module __MODULE__
  @moduledoc """
  This module is the Repository for Aggregates, Process Managers, or anything else that has a PID
  and you want to store and load the state from cache, from some snapshot, replay events from that
  snapshot or even from the begining. For several reasons we choosed SYN to store pids. Note that
  the BPE https://github.com/spawnproc/bpe also choosed SYN. 
  http://www.ostinelli.net/an-evaluation-of-erlang-global-process-registries-meet-syn/
  https://github.com/ostinelli/syn
  TODO: add TTL for aggregates.
  """

  require Logger
  alias Engine.Aggregate
  alias Engine.EventStore


  @doc "Open an aggregate from cache, snapshot, events, and if not found, create a new one"
  def open_aggregate(module, uuid) do #when is_integer(uuid) or is_atom(uuid) or is_bitstring(uuid) do
    #uuid = to_string(uuid)
    case :syn.find_by_key(uuid) do
      :undefined ->
        pid = start_aggregate(Engine.Aggregate.Supervisor, module, uuid)
        Logger.info "Repository starting aggregate #{uuid}"
        add_to_cache(uuid, pid)
        {:ok, pid}
      pid ->
        Logger.info "Repository found aggregate #{uuid} on cache"
        {:ok, pid}
    end
  end


  #######################
  # INTERNAL FUNCTIONS  #
  #######################

  defp start_aggregate(supervisor, module, uuid) do
    {:ok, pid} = Aggregate.Supervisor.start_aggregate(supervisor, module, uuid)
    add_to_cache(uuid, pid)
    Process.monitor(pid)
    pid
  end

  defp add_to_cache(id, pid), do:
    :syn.register(id, pid, :undefined)

  # ok | {error, Error}, Error = taken | pid_already_registered 
  defp remove_from_cache(id), do:
    :syn.unregister(id)


end
