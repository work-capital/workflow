defmodule Workflow.Middleware.Pipeline do
  @moduledoc """
  Pipeline is a struct used as an argument in the callback functions of modules implementing the `Commanded.Middleware` behaviour.

  This struct must be returned by each function to be used in the next middleware based on the configured middleware chain.

  ## Pipeline fields

    * `assigns` - shared user data as a map
    * `message` - the message struct being dispatched
    * `halted` - the boolean status on whether the pipeline was halted
    * `response` - override the response to send back to the caller (optional)

  """

  defstruct [
    assigns: %{},
    data: nil,
    message: nil,
    halted: false,
    response: nil,
  ]

  alias Workflow.Middleware.Pipeline

  @doc """
  Puts the `key` with value equal to `value` into `assigns` map
  """
  def assign(%Pipeline{assigns: assigns} = pipeline, key, value) when is_atom(key), do:
    %Pipeline{pipeline | assigns: Map.put(assigns, key, value)}

  @doc """
  Halts the pipeline by preventing further middleware downstream from being invoked.
  Prevents dispatch of the command if `halt` occurs in a `before_dispatch` callback.
  """
  def halt(%Pipeline{} = pipeline), do:
    %Pipeline{pipeline | halted: true}

  @doc """
  Sets the response to be returned to the dispatch caller
  """
  def respond(%Pipeline{} = pipeline, response), do:
    %Pipeline{pipeline | response: response}


  @doc """
  Implements the middleware chain
  """
  def chain(pipeline, stage, middleware)
  def chain(pipeline, _stage, []), do: pipeline
  def chain(%Pipeline{halted: true} = pipeline, _stage, _middleware), do: pipeline
  def chain(pipeline, stage, [module | modules]) do
    chain(apply(module, stage, [pipeline]), stage, modules)
  end
end
