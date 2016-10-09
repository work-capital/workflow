defmodule AggregateHandler do
  require Logger
  @moduledoc """
  Generic Event Handler to use with the CQRS framework
  Generic Aggregate module.

  ## Example
  """

  defmacro __using__(_) do
    quote do
      use GenEvent
      import AggregateHandler
      #import __MODULE__
      ## Event Bus
      alias Engine.Bus
      #require Logger
      def init([]),         do: {:ok, []}
      def add_handler(),    do: Bus.add_handler(__MODULE__, [])
      def remove_handler(), do: Bus.remove_handler(__MODULE__, [])

      def handle_call(_, state),      do: {:ok, state}
      def handle_info(_, state),      do: {:ok, state}
      def terminate(_reason, _state), do: :ok
      def code_change(_old_vsn, state, _extra), do: {:ok, state}
      @before_compile unquote(__MODULE__)  # catch events that are not for this
                                           # handler. (are from other handlers
    end
  end


  defmacro handle_create(com, aggregate, supervisor, do: block) do
    ast = quote do
      def handle_event(com = unquote(com), state) do
        Logger.info "Handle Create Command: #{inspect com}"
        case Engine.Repository.get_by_id(com.id, unquote(aggregate), unquote(supervisor)) do
          :not_found ->
            {:ok, pid2} = unquote(supervisor).new
            var!(pid) = pid2
            var!(command) = com
            unquote(block)
            Engine.Repository.save(pid2, unquote(aggregate))
            {:ok, pid2}
          {:ok, pid2} ->
            {:ok, pid2}
        end
      end
    end
    #Logger.debug Macro.to_string(ast)
    ast
  end


  defmacro handle_command(com, aggregate, supervisor, do: block) do
    quote do
      def handle_event(com = unquote(com), state) do
        Logger.info "Handle Command: #{inspect com}"
        case Engine.Repository.get_by_id(com.id, unquote(aggregate), unquote(supervisor)) do
          :not_found ->
            Logger.error("No account found for: ~p~n",[com.id])
            {:error, :not_found}
          {:ok, pid2} ->
            var!(pid) = pid2
            var!(command) = com
            #Account.Aggregate.deposit(pid2, com.amount)
            unquote(block)
            Engine.Repository.save(pid2, unquote(aggregate))
            {:ok, pid2}
        end
      end
    end
  end

  defmacro __before_compile__(_env) do     # injected at the end of the code!
    quote do                               # before compile = after expansion
      def handle_event(_,_), do: {:ok, self}
    end
  end

end



  # defmacro handle_create(cmd , aggregate, supervisor, do: block) do
  #   ast = quote bind_quoted: [
  #       aggregate: aggregate,
  #       supervisor: supervisor,
  #       cmd: cmd,
  #       block: block
  #       #block: Macro.escape(block, unquote: true)
  #     ] do
  #     def handle_event(com = cmd, state) do
  #       Logger.info "Handle Create Command: #{inspect com}"
  #       case Engine.Repository.get_by_id(com.id, aggregate, supervisor) do
  #         :not_found ->
  #           {:ok, pid2} = supervisor.new
  #           var!(pid) = pid2
  #           var!(command) = com
  #           block
  #           Engine.Repository.save(pid2, aggregate)
  #           {:ok, pid2}
  #         {:ok, pid2} ->
  #           {:ok, pid2}
  #       end
  #     end
  #   end
  #   Logger.debug Macro.to_string(ast)
  #   ast
  # end
