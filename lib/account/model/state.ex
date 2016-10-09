defmodule Account.Model.State do
  #@derive {Poison.Encoder, except: [:changes]}
  # TODO: add to docs: all states must have :event_counter and :changes
  defstruct id: nil,
            date_created: nil,
            balance: nil,
            event_counter: nil,
            changes: []              # ---> should be initialized as [] !
  @type t :: %Account.Model.State{}
end
