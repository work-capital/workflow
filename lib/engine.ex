defmodule Engine do
  use Application
  require Logger
  # TODO: refactor to have a clean and readble server starting (use maybe from monadex)
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @doc "Start the supervisor and activate its handlers"
  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    start_syn()     # SYN --> https://github.com/ostinelli/syn
    # Engine.KeyPID.init()  TODO: start syn

    # we should start the CQRS before, so the BUS will be ready for use, and aggregates
    # will be able to access the Bus
    children = [
      supervisor(Engine.Supervisor, [])
    ]
    opts = [strategy: :one_for_one, name: Engine.Supervisor]
    app_response = Supervisor.start_link(children, opts)

    # return the main application
    app_response
  end

  # Ensure that Syn is initialized only once on a node. [see doc]
  def start_syn() do
    :syn.start()
    # http://benjamintan.io/blog/2014/05/25/connecting-elixir-nodes-on-the-same-lan/
    # nodes = Application.get_env(:engine, :nodes)
    #[Node.connect(Node) || Node <- Nodes]   # connect to nodes
    :syn.init()                # start the registry database
  end

end
