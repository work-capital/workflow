defmodule Engine.Config do
  @moduledoc """
  It gives the configuration value based on key, but if the configuration was not
  specified in the config.exs file, the default configuration will be used
  """

  @application_name :engine
  @default_config %{
    eventstore_host: "127.0.0.1",
    eventstore_port: 1000,
    snapshot_period: 50
  }

  @doc """
    We get the default value from the map.
    ## Examples
    iex> Engine.Config.get(:redis_port)
    6555
  """
  def get(key) do
    Map.get(@default_config, key)
      |> get(key)
  end


  @doc """
  It return the value for the input key, if not found, it will use the 
  fallback as a value instead
    ## Examples
    iex> Engine.Config.get(:fall_back_this, :this_config_doesnot_exist)
    :fall_back_this
  """
  def get(fallback, key) do
    Application.get_env(@application_name, key, fallback)
  end
end
