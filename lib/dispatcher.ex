defmodule Workflow.Dispatcher do
  @moduledoc"""
  Dispatch commands and events (messages) to aggregates and process managers
  """
  require Logger

  alias Workflow.Repository
  alias Workflow.Container

  def dispatch(message, module, uuid, timeout) do
    Logger.debug(fn -> "attempting to dispatch message: #{inspect message}, to: module: #{inspect module}" end)
    {:ok, container} = Repository.open(module, uuid)
    Container.execute(container, message, timeout)
  end


end
