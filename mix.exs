defmodule Engine.Mixfile do
  use Mix.Project

  def project do
    [app: :engine,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    #[applications: [:mongodb, :poolboy, :logger, :exsync],
    [applications: [:calendar, :mongodb, :poolboy, :logger],
     mod: {Engine, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  #{:extreme,  git: "https://github.com/work-capital/extreme", branch: "master"}, # trying last pushes
  defp deps do
    [
      #{:gen_stage, "~> 0.5"},   # substitute gen_event, add parallelist and backpresure for streams
      {:mongodb, "~> 0.1.1"},   # support mongo 3.2, pools, etc.. [https://github.com/ericmj/mongodb]
      {:poolboy, "~> 1.5"},     # pool for mongodb
      {:sweet_xml, "~> 0.6.1"}, # wrapper for the erlang native XML parser (NFe)
      {:extreme, "~> 0.6.0"},   # eventstore driver
      {:calendar, "~> 0.16.1"},  # for easy calendar calculations [hex.pm/packages/calendar]
      {:syn, "~> 1.5"}, # much more simple and powerfull than gproc, Alex
      {:uuid, "~> 1.1.4" },
      {:logger_file_backend, "~> 0.0.9"},  # Save logs to file  [remmember to create a ~/logs directory!]
			# DEVs
			{:dogma, "~> 0.1.7", only: [:dev]},      # code linter
      {:dialyxir, "~> 0.3.5", only: [:dev]},   # simplify dialyzer, type: mix dialyzer.plt first
			{:mix_test_watch, "~> 0.2", only: :dev}  # use mix test.watch for TDD development
    ]
  end
end
