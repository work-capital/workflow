Engine
======

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
* lib/company - a real aggregator for to manage company data, registration,
  contracts, etc...
* lib/obligation - aggregator
* lib/user - aggregator
* lib/account - the graphaccount aggregator. for the sake of brevity, let's call
  it account


## Links

https://robots.thoughtbot.com/testing-a-phoenix-elixir-json-api
https://github.com/maxcnunes/elixir-phoenix-rest-api
https://www.coshx.com/blog/2016/03/16/json-api-with-phoenix/
https://blog.codeship.com/an-introduction-to-apis-with-phoenix/


### Eventstore
Run a [docker](https://github.com/EventStore/eventstore-docker) instance in your machine. If you have mac, ask the sys-admin to start it in a linux server on you LAN or WAN. Access the web gui in http://localhost:2113 . User: admin, pass: changeit


```
docker run --name eventstore-node -it -p 2113:2113 -p 1113:1113 eventstore/eventstore
```

