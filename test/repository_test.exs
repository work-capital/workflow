defmodule RepositoryTest do
  use ExUnit.Case

  alias Workflow.Domain.Account
  alias Workflow.Repository

  test "the truth" do
    container = Repository.start_container(Account, "my-uuid")
    data = Workflow.Container.get_data(container)
    IO.inspect data
    assert 1 + 1 == 2
  end
end
