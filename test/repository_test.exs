defmodule RepositoryTest do
  use ExUnit.Case

  alias Workflow.Container
  alias Workflow.Domain.Account
  alias Workflow.Repository

  alias Workflow.Domain.Counter

  alias Counter.Commands.{Add, Remove}
  alias Counter.Events.{Added, Removed}


  test "simulation using pure functional data structures" do
    # generate event
    ev1 = %Counter{}
      |> Counter.handle(%Add{quantity: 7})

    # apply
    c = %Counter{}
      |> Counter.apply(ev1)

    # generate event over the last state
    ev2 = c |> Counter.handle(%Remove{quantity: 3})

    # apply
    c2 = %Counter{}
      |> Counter.apply(ev2)

    assert c2 == %Counter{counter: 4} 
  end


  #test "simulate using side effects" do
    # stream_id = "repository-test-01-" <> UUID.uuid4
    # container = Repository.start_container(Counter, stream_id)
    # # process two commands
    # res1 = Container.process_message(container, %Add{quantity: 7})
    # res2 = Container.process_message(container, %Remove{quantity: 3})
    # # get state data
    # data = Container.get_data(container)
    # state = Container.get_state(container)
    # IO.inspect state
    # IO.inspect res1
    #
    # assert data== %Counter{counter: 4}  #  7 - 3 = 4
    #end


end
