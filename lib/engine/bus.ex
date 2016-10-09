defmodule Engine.Bus do
  @server __MODULE__

  @moduledoc """
  The Bus receives commands and events from the API and publish them, so the handlers may take
  care of the commands and events to apply them to the suitable aggregates.
  TODO: use eventstore eventbus with extreme, see: https://github.com/exponentially/extreme
  """
  def start_link(), do:
    GenEvent.start_link([{:name, @server}])

  def add_handler(handler, args), do:
    GenEvent.add_handler(@server, handler, args)

  def remove_handler(handler, args), do:
    GenEvent.remove_handler(@server, handler, args)

  # def send_command(timestamp, server_name, command) do
  #GenEvent.notify(@server, {:command, timestamp, server_name, command})
  # end
  #
  def send_command(command), do:
    GenEvent.notify(@server, command)

  def publish_event(event), do:
    GenEvent.notify(@server, event)

end
