# Original Work: Copyright (c) 2016 Ben Smith (ben@10consulting.com)
defmodule Engine.Aggregate.Aggregate do
  defmacro __using__(fields: fields) do
    quote do
      import Kernel, except: [apply: 2]
      @module __MODULE__
      @default_snapshot 5  # TODO: get from settings

      defstruct uuid: nil,                # unique id
                counter: 0,               # event counter, we receive the event position from the db
                version: 0,
                pending_events: [],       # events pending to be applied [we reset it after applying
                snapshot_period: 40,
                state: nil

      defmodule State, do: defstruct unquote(fields)

      # @doc "Create a new aggregate struct given a unique identity"
      # def new(uuid), do:
      #   %@module{uuid: uuid, snapshot_period: @snapshot_p, state: %@module.State{} }

      @doc "Create a new aggregate struct given a unique identity and a custom snapshot period"
      def new(uuid, snapshot_period \\ @default_snapshot), do:
        %@module{uuid: uuid, snapshot_period: snapshot_period, state: %@module.State{}}

      @doc "Create a new aggregate struct from a given aggregate with its previous state"
      def load(%@module{uuid: uuid, snapshot_period: snapshot_period, 
                        counter: counter, state: state}, events) when is_list(events) do

        event_l = length(events)
        counter = counter + event_l    # the position is what was on state + the number of events
        new_state =
          Enum.reduce(events, state, &@module.apply(&2, &1))
          %@module{uuid: uuid, snapshot_period: snapshot_period, 
                   counter: counter, state: new_state, version: event_l, pending_events: []}
      end

      @doc "Rebuild the aggregate's state from a given list of previously raised domain events"
      def load(uuid, events) when is_list(events) do
        state =
          Enum.reduce(events, %@module.State{}, &@module.apply(&2, &1))
          event_l = length(events) # since we played from scratch, the event length = counter
          %@module{uuid: uuid, counter: event_l, state: state, version: event_l, pending_events: []}
      end


      # Receives a single event and is used to mutate the aggregate's internal state.
      defp update(%@module{uuid: uuid, counter: counter, version: version, 
                           pending_events: pending_events, state: state} = aggregate, event) do
        version = version + 1
        state = @module.apply(state, event)
        pending_events = pending_events ++ [event]
        counter = counter + 1            # called per event, so we +1 event

        %@module{aggregate |
          counter: counter,
          pending_events: pending_events,
          state: state,
          version: version
        }
      end

    end
  end
end

