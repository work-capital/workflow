CQRS Eventsourcing Engine
=========================

### Thanks
Special thanks to [burmajam](https://github.com/burmajam) for sharing the very 
well written extreme driver to connect to Eventstore. 


### TODO's 



We are using TDD [Test Driven Development] here, so use the command below to
stay connected with your tests and recompile automaitcally every save.

```
mix test.watch
```

Send events from the prompt:

```
iex -S mix

Engine.Bus.send_command(%{%Account.Command.CreateAccount{} | :id => "jsdf"})
Engine.Bus.send_command(%{%Account.Command.DepositMoney{} | :id => "jsdf", :amount => 23})
```

## Directory Structure
* lib/engine - main app, where all start. It should start your aggregator, process
  maangers, etc.. supervisors, static modules to help access data, etc.., also
  contains the CQRS framework, with its macros. Note that macros are not using
  the namespace. All the common files are here. 
* account - example with an account bank aggregator. 
* account/command - structs with account commands 
* account/event   - structs with account events 
* account/handler - command and event handlers, using macros. 
* acount/model - state struct
* account/supervisor.ex - supervisor for this aggregate



## Resources
Below you can see several resources I researched before writing this lib. 

* [cqrs-erlang](https://github.com/bryanhunter/cqrs-with-erlang) - A memory
  model using standard spawn functions CQRS in erlang. 
* [gen-aggregate](https://github.com/burmajam/gen_aggregate/) - Macro for the
  aggregate structure, using buffers. 
* [cqrs-journey](https://msdn.microsoft.com/en-us/library/jj554200.aspx) - A
  complete book on CQRS, with an OO approach. 

* **JSON API** 
https://robots.thoughtbot.com/testing-a-phoenix-elixir-json-api 
https://github.com/maxcnunes/elixir-phoenix-rest-api 
https://www.coshx.com/blog/2016/03/16/json-api-with-phoenix/ 
https://blog.codeship.com/an-introduction-to-apis-with-phoenix/ 


### Eventstore
Run a [docker](https://github.com/EventStore/eventstore-docker) instance in your machine. If you have mac, ask the sys-admin to start it in a linux server on you LAN or WAN. Access the web gui in http://localhost:2113 . User: admin, pass: changeit


```
docker run --name eventstore-node -it -p 2113:2113 -p 1113:1113 eventstore/eventstore
```


#### CQRS concepts

http://softwareengineering.stackexchange.com/questions/157522/cqrs-event-sourcing-is-it-correct-that-commands-are-generally-communicated 


If something sends a command, it entails expectation that it will be fulfilled. If you simply publish and hope that something somewhere picks it up and acts on it, there is no guarantee that this will be the case. By extrapolation, you also don't know if multiple handlers don't decide to act on a command, possibly resulting in the same change being applied more than once. 

Events, on the other hand, are informative in nature, and it's reasonable to expect zero, two, or more components to be interested in a particular event. We don't really care in the scope of making the requested change. 

**Example** 

This could be compared to real life. If you have three children, walk into a room and simply shout "Clean the bathroom," you have no guarantee that someone will, and perhaphs if it won't be done twice (if you have obedient children that is ;-) You should fare better if you assign a specific child to do what you want done. 

When that child finishes its job however, it's convenient if it shouts out "bathroom has been cleaned," so that everyone who wants to brush their teeth knows they can now do so. 





