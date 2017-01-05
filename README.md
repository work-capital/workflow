CQRS Eventsourcing Workflow Engine
==================================

[![Join the chat at https://gitter.im/cqrs-engine/Lobby](https://badges.gitter.im/cqrs-engine/Lobby.svg)](https://gitter.im/cqrs-engine/Lobby?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

### IMPORTANT
Only the data structures are working, for testing and collecting feedbacks. 
We believe that at the begining of December 2016, the framework will be usable.


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
* one abstraction to implement side-effects
* multiple data-stores
* plugable message queue for publishing events
* one gen_server implementation for aggregates and process managers
* automatic process-manager creation based on correlation-ids (as suggested by Greg Young)
* easy use of FSM on process managers

### Develop

```
mix test.watch
```

Send events from the prompt:

```
iex -S mix
TODO: add example

```


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


