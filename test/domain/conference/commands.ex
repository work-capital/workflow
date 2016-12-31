defmodule Workflow.Domain.Conference.Commands do
  defmodule MakeSeatReservation,
    do: defstruct [uuid: nil]
  defmodule CommitSeatReservation,
    do: defstruct [uuid: nil]
  defmodule CancelSeatReservation,
    do: defstruct [uuid: nil]
end
