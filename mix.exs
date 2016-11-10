defmodule Engine.Mixfile do
  use Mix.Project

  def project do
    [app: :engine,
     version: "0.1.1",
     elixir: "~> 1.3",
     description: description(),
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end


  def application do
    [applications: [:calendar, :mongodb, :poolboy, :logger],
     mod: {Engine, []}]
  end

  defp deps do
    [
      #{:gen_stage, "~> 0.5"},   # substitute gen_event, add parallelist and backpresure for streams
      {:poolboy, "~> 1.5"},      # pool for mongodb
      {:sweet_xml, "~> 0.6.1"},  # wrapper for the erlang native XML parser (NFe)
      # storages
      {:extreme, "~> 0.6.0"},    # eventstore driver
      {:eventstore, "~> 0.6.1"}, # postgres   driver [mix event_store.create]
      {:mongodb, "~> 0.1.1"},    # support mongo 3.2, pools, etc.[https://github.com/ericmj/mongodb]
      # utils
      {:monadex, "~> 1.0"},
      {:calendar, "~> 0.16.1"},  # for easy calendar calculations [hex.pm/packages/calendar]
      {:syn, "~> 1.5"}, # much more simple and powerfull than gproc, Alex
      {:uuid, "~> 1.1.4" },
      {:logger_file_backend, "~> 0.0.9"},  # Save logs to file  [remmember to create a ~/logs directory!]
			# DEVs
			{:dogma, "~> 0.1.7", only: [:dev]},      # code linter
      {:dialyxir, "~> 0.3.5", only: [:dev]},   # simplify dialyzer, type: mix dialyzer.plt first
			{:mix_test_watch, "~> 0.2", only: :dev}, # use mix test.watch for TDD development
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end


  defp package do
    [# These are the default files included in the package
     name: :engine,
     files: ["lib", "test", "config", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Henry Hazan", "Shmuel Kalmus"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/work-capital/engine"}]
  end


   defp description do
    """
    Building Blocks to write CQRS Event Sourcing apps in Elixir
    """
  end


end
