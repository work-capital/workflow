defmodule Workflow.Config do
  @default_config %{
    name: Workflow,
    mode: :default,
    host: "127.0.0.1",
    namespace: "exq",
    adapter: Workflow.Adapter.Extreme,
    snapshot_period: 50,
    batch_size: 100,
    serializer: JsonSerializer,
    middleware: [
      Workflow.Middleware.ProcessManager,
      Workflow.Middleware.Command,
      Workflow.Middleware.Logger
    ]
  }

  def get(key), do:
    get(key, Map.get(@default_config, key))

  def get(key, fallback), do:
    Application.get_env(:exq, key, fallback)

  def serializer, do:
    get(:serializer)

  def batch_size, do:
    get(:batch_size)

end
