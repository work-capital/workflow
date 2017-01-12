# load files for test
# http://stackoverflow.com/questions/30652439/importing-test-code-in-elixir-unit-test
Code.require_file("test/domain/counter/counter.exs")
Code.require_file("test/domain/account/account.exs")
ExUnit.start()
