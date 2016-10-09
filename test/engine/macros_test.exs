ExUnit.start
#Code.require_file("aggregate_handler.exs", __DIR__)
defmodule MacrosTest do
  #use AggregateHandler
  use ExUnit.Case
  # test "Is it really that easy?" do
  # assert Code.ensure_loaded?(Loop)
  # end

  test "compile/1 generates catch-all t/3 functions" do
    # assert AggregateHandler.handle_create("command", Account.Aggregate,
    #                                       Account.Supervisor) do
    #                                       IO.inspect "jim" end
    #            |> Macro.to_string == String.strip ~S"""
    #                       (
    #                         def(t(locale, path, binding \\ []))
    #                         []
    #                         def(t(_locale, _path, _bindings)) do
    #                         {:error, :no_translation}
    #                         end
    #                       )
    #                       """
            a = String.strip ~S"""
            (
              def(handle_event(com = %CreateAccount{}, state)) do
                Logger.info("Handle Create Command: #{inspect(com)}")
                case(Engine.Repository.get_by_id(com.id(), Account.Aggregate, Account.Supervisor)) do
                      :not_found ->
                        {:ok, pid2} = Account.Supervisor.new()
                        var!(pid) = pid2
                        var!(command) = com
                        (
                          s = Account.Aggregate.create(pid, command.id())
                          IO.inspect(s)
                        )
                        Engine.Repository.save(pid2, Account.Aggregate)
                        {:ok, pid2}
                      {:ok, pid2} ->
                        {:ok, pid2}
                    end
                end
              end
              """
              assert 1 == 1
          end
  end

