  defmodule Engine.Example.Manager do
    alias RegistrationProcess.Data
    use Fsm,
      initial_state: :non_started, data: [], subscriptions: [ %OrderPlaced{}, %ReservationAccepted{},
                     %ReservationAccepted{}, %PaymentReceived{}]

    # NON-STARTED
    defstate non_started do

      defevent handle(%OrderPlaced{} = order), data: commands do
        commands = commands
          |> dispatch(%MakeSeatReservation{})
        respond(:ok, :awaiting_reservation, commands)
      end

      defevent _, do: respond(:error, :invalid_operation)
    end

    # AWAITING RESERVATION CONFIRMATION
    defstate awaiting_reservation do

      defevent handle(%ReservationAccepted{id: id} = reservation), data: commands do
        commands = commands
          |> dispatch(%MarkOrderAsBooked{})
          |> dispatch(%ExpireOrder{})
        respond(:ok, :awaiting_payment, commands)
      end


      defevent handle(%ReservationRejected{} = reservation), data: commands do
        commands = commands
          |> dispatch(%RejectOrder{})
        respond(:ok, :completed, commands)
      end

      defevent _,
        do: respond(:error, :invalid_operation)

    end

    # AWAITING PAYMENT
    defstate awaiting_payment do

      defevent handle(%OrderPlaced{} = order), data: commands do
        commands = commands
          |> dispatch(%CancelSeatReservation{})
          |> dispatch(%RejectOrder{})
        respond(:ok, :completed, commands)
      end

      defevent handle(%PaymentReceived{} = payment), data: commands do
        commands = commands
          |> dispatch(%CommitSeatReservation{})
        respond(:ok, :completed, commands)
      end

      defevent _,
        do: respond(:error, :invalid_operation)
    end

    # COMPLETED
    defstate completed do
      defevent _,
        do: respond(:error, :invalid_operation)
    end

  end



