CQRS Eventsourcing Engine
=========================

### Thanks
Special thanks to: 

[burmajam](https://github.com/burmajam) for sharing the very 
well written extreme driver to connect to Eventstore. 

[slashdotdash](https://github.com/slashdotdash/commanded) for sharing the CQRS
framework, where many parts of the code here are from his framework.


### Motivation

* pure functional data structures for aggregates and process managers
* one abstraction to implement side-effects
* multiple data-stores



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

## Resources
Below you can see several resources I researched before writing this lib. 

* [cqrs-erlang](https://github.com/bryanhunter/cqrs-with-erlang) - A memory
  model using standard spawn functions CQRS in erlang. 
* [gen-aggregate](https://github.com/burmajam/gen_aggregate/) - Macro for the
  aggregate structure, using buffers. 
