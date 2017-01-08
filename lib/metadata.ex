defmodule Workflow.Metadata do

  @moduledoc """
  Metadata for every message (command, event, etc..)
  """
  defstruct message_id: nil,
            correlation_id: nil,
            causation_id: nil

  @type t :: %Workflow.Metadata{
    message_id: String.t,
    correlation_id: String.t,
    causation_id: String.t
  }

end


