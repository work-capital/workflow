CQRS Eventsourcing Engine
=========================

### IMPORTANT
Only the data structures are working, for testing and collecting feedbacks. 
We believe that at the begining of December 2016, the framework will be usable.

### Thanks
Special thanks to: 

[burmajam](https://github.com/burmajam) for sharing the very 
well written extreme driver to connect to Eventstore. 

[slashdotdash](https://github.com/slashdotdash/commanded) for sharing the CQRS
framework, where many parts of the code here are from his framework.


### Motivation

### Pure functions data structures
In the folder engine > types you will find the data structures, so you can write
your pure functions over them, under the "side effects" dimension. 

1. A pure function is given one or more input parameters.
2. Its result is based solely off of those parameters and its algorithm. The algorithm will not be based on any hidden state in the class or object it’s contained in.
3. It won’t mutate the parameters it’s given.
4. It won’t mutate the state of its class or object.
5. It doesn’t perform any I/O operations, such as reading from disk, writing to disk, prompting for input, or reading input.


### Motivation

* pure functional data structures for aggregates and process managers
* one abstraction to implement side-effects
* multiple data-stores
* plugable message queue for publishing events

### Develop

```
mix test.watch
```

Send events from the prompt:

```
iex -S mix

Engine.Bus.send_command(%{%Account.Command.CreateAccount{} | :id => "jsdf"})
Engine.Bus.send_command(%{%Account.Command.DepositMoney{} | :id => "jsdf", :amount => 23})
```


### Eventstore
Run a [docker](https://github.com/EventStore/eventstore-docker) instance in your machine. If you have mac, ask the sys-admin to start it in a linux server on you LAN or WAN. Access the web gui in http://localhost:2113 . User: admin, pass: changeit


```
docker run --name eventstore-node -it -p 2113:2113 -p 1113:1113 eventstore/eventstore
```

#### Resources
Below you can see several resources I researched before writing this lib. 

* [cqrs-erlang](https://github.com/bryanhunter/cqrs-with-erlang) - A memory
  model using standard spawn functions CQRS in erlang. 
* [gen-aggregate](https://github.com/burmajam/gen_aggregate/) - Macro for the
  aggregate structure, using buffers. 


#### CQRS concepts

http://softwareengineering.stackexchange.com/questions/157522/cqrs-event-sourcing-is-it-correct-that-commands-are-generally-communicated 


If something sends a command, it entails expectation that it will be fulfilled. If you simply publish and hope that something somewhere picks it up and acts on it, there is no guarantee that this will be the case. By extrapolation, you also don't know if multiple handlers don't decide to act on a command, possibly resulting in the same change being applied more than once. 

Events, on the other hand, are informative in nature, and it's reasonable to expect zero, two, or more components to be interested in a particular event. We don't really care in the scope of making the requested change. 

**Example** 

This could be compared to real life. If you have three children, walk into a room and simply shout "Clean the bathroom," you have no guarantee that someone will, and perhaphs if it won't be done twice (if you have obedient children that is ;-) You should fare better if you assign a specific child to do what you want done. 

When that child finishes its job however, it's convenient if it shouts out "bathroom has been cleaned," so that everyone who wants to brush their teeth knows they can now do so. 





