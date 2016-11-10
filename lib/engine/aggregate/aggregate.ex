# Original Work: Copyright (c) 2016 Ben Smith (ben@10consulting.com)
defmodule Engine.Aggregate.Aggregate do
  defmacro __using__(fields: fields) do
    quote do
      import Kernel, except: [apply: 2]
      @module __MODULE__

      defstruct uuid: nil, version: 0, pending_events: [], state: nil

      defmodule State, do: defstruct unquote(fields)

      @doc "Create a new aggregate struct given a unique identity"
      def new(uuid), do: %@module{uuid: uuid, state: %@module.State{}}

      @doc "Create a new aggregate struct from a given aggregate with its previous state"
      def load(%@module{uuid: uuid, state: state}, events) when is_list(events) do
        new_state =
          Enum.reduce(events, state, &@module.apply(&2, &1))
          %@module{uuid: uuid, state: new_state, version: length(events), pending_events: []}
      end

      @doc "Rebuild the aggregate's state from a given list of previously raised domain events"
      def load(uuid, events) when is_list(events) do
        state =
          Enum.reduce(events, %@module.State{}, &@module.apply(&2, &1))
          %@module{uuid: uuid, state: state, version: length(events), pending_events: []}
      end

      # Receives a single event and is used to mutate the aggregate's internal state.
      defp update(%@module{uuid: uuid, version: version, pending_events: pending_events, state: state} = aggregate, event) do
        version = version + 1
        state = @module.apply(state, event)
        pending_events = pending_events ++ [event]

        %@module{aggregate |
          pending_events: pending_events,
          state: state,
          version: version
        }
      end

    end
  end
end

