CQRS Eventsourcing Workflow Engine
==================================

*IMPORTANT*: use only for research, and please, feedback. we will update when we
start using in production



### Pure functions data structures
In the folder engine > types you will find the data structures, so you can write
your pure functions over them, under the "side effects" dimension. 

1. A pure function is given one or more input parameters.
2. Its result is based solely off of those parameters and its algorithm. The algorithm will not be based on any hidden state in the class or object it’s contained in.
3. It won’t mutate the parameters it’s given.
4. It won’t mutate the state of its class or object.
5. It doesn’t perform any I/O operations, such as reading from disk, writing to disk, prompting for input, or reading input.


### Motivation

As aggregates listen for commands, process managers listen for events (sometimes commands also), and as aggregates emmits events, process managers dispatch commands.

* pure functional data structures for aggregates and process managers
* use monads (monadex) to simulate different business scenarios
* once aggregates, process managers and sagas are receive messages and has a
  state, use one source code (container.ex) to hold them all, simplifying the
  implementation
* flexible pipelines for all messaging processing and state mutation
* one abstraction to implement side-effects
* multiple data-stores from scratch
* one event router for all process managers or sagas, using assync dispatch, to rebuild
  or load them from memory.
* plugable message queue for publishing events.
* automatic process-manager creation based on correlation-ids (as suggested by Greg Young)



### Automatic Metadata Atribuition by Pipelines
Let's say every message has 3 ids.
 - message ID
 - correlation ID
 - causation ID 
 

When you are responding to a message (either a command or and event) you copy the correlation-ID of the message you are responding to to your message. The Causation-ID of your message is the Message-ID of the message you are responding to. 

This allows you to see an entire conversation (correlation id) or to see what causes what (causation id). Correlation and causation ids in your commands and events, make it easer to find out what really happened in a so decoupled system.


### Develop

```
mix test.watch
```

Send events from the prompt:

```
iex -S mix
TODO: add example

```


### Message Flow
You can use pipelines to determine different flows for aggregates, process
managers and sagas.


#### Aggregate Flow

```elixir
defmodule Workflow.Domain.Counter do
  defstruct [
    counter: 0
  ]

  # commands & events
  defmodule Commands do
    defmodule Add,    do: defstruct [amount: nil]
    defmodule Remove, do: defstruct [amount: nil]
  end

  defmodule Events do
    defmodule Added,   do: defstruct [amount: nil]
    defmodule Removed, do: defstruct [amount: nil]
  end

  # aliases
  alias Commands.{Add, Remove}
  alias Events.{Added, Removed}
  alias Workflow.Domain.Counter

  # handlers
  def handle(%Counter{counter: counter}, %Add{amount: amount}), do:
    %Added{amount: amount}

  def handle(%Counter{counter: counter}, %Remove{amount: amount}), do:
    %Removed{amount: amount}

  # state mutatators
  def apply(%Counter{counter: counter} = state, %Added{amount: amount}), do:
    %Counter{state | counter: counter + amount}

  def apply(%Counter{counter: counter} = state, %Removed{amount: amount}), do:
    %Counter{state | counter: counter - amount}

end
```
*FLOW FROM EXTERNAL SOURCE* 

1. Command arrives the system from external source and is dispatched:
   (The causation-id is in this case is the request-id)
     Router.dispatch(%Add{amount: amount},
                     causation_id}

2. Arrives and assure message has uuid, if not, it creates one.

3. Command goes to pipeline, and the pipeline adds the sent id to the
   causation id, and creates a new uuid for this command.

      %Add{amount: amount, initiator: true}      -> initiator command!
      %{message_id: "uuid-1", causation_id: "rest-id"}

5. Pipeline take only the Command message to the aggregate and make the
   aggregate to handle it.

6. After handling, and without failing, pipeline catches the zero, one or more events resulted from that command,
and add for every event the metadata below. Note that because the command above
is an "initiator", pipeline will automatically copy the event message_id to the
correlation_id field. And from now, this event, when emited by the eventstore,
ROUTER will get it and send to dispatcher, so a process manager with the
correlation_id below will start.

      %Added{amount: amount}
      %{message_id: "uuid-2", causation_id: "uuid-1", correlation_id: "uuid-2"}

7. Pipeline apply this event, and mutate state

8. Pipeline send this event with the meta-data to persistence.


*FLOW FROM PROCESS MANAGER*

1. Event arrives at ROUTER, and are filtered, only events that have correlation_id - they cause the dispatcher to make 
the repository "replay" the process manager until it's correct state (or retreive from a snapshot (in future versions))

2. Filtered event will arrive and 



### Eventstore
Run a [docker](https://github.com/EventStore/eventstore-docker) instance in your machine. If you have mac, ask the sys-admin to start it in a linux server on you LAN or WAN. Access the web gui in http://localhost:2113 . User: admin, pass: changeit


```
docker run --name eventstore-node -it -p 2113:2113 -p 1113:1113 eventstore/eventstore
```

#### Resources
Below you can see several resources I researched before writing this lib.
Special thanks for Ben Smith, where many ideas were copied from
[commanded](https://github.com/slashdotdash/commanded) library.

* [burmajam](https://github.com/burmajam) for sharing the very 
well written extreme driver to connect to Eventstore. 
* [slashdotdash](https://github.com/slashdotdash/commanded) for sharing the CQRS
framework, where many parts of the code here are from his framework.
* [cqrs-erlang](https://github.com/bryanhunter/cqrs-with-erlang) - A memory
  model using standard spawn functions CQRS in erlang. 
* [gen-aggregate](https://github.com/burmajam/gen_aggregate/) - Macro for the
  aggregate structure, using buffers. 


