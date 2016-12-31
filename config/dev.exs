use Mix.Config


#-------------------------------
#  LOGGER
#-------------------------------


config :logger,
  backends: [{LoggerFileBackend, :log_info},
             {LoggerFileBackend, :log_error},
             {LoggerFileBackend, :log_debug},
             :console]
  # handle_otp_reports: true,
  # handle_sasl_reports: true
config :logger, :console,
    format: "\n$time $metadata[$level] $levelpad$message\n",
    colors: [info: :magenta],
    metadata: [:module, :function, :id, :uuid]

config :logger, :log_debug,
  path: "./logs/debug.log",
  metadata: [:pid, :application, :module, :file, :function, :line, :id, :uuid],
  format: "$dateT$time $node $metadata[$level] $levelpad$message\n",
  level: :debug

config :logger, :log_info,
  metadata: [:module, :pid, :id, :uuid],
  format: "$dateT$time $node $metadata[$level] $levelpad$message\n",
  path: "./logs/info.log",
  level: :info

config :logger, :log_error,
  path: "./logs/error.log",
  metadata: [:pid, :application, :module, :file, :line, :id, :uuid],
  format: "$dateT$time $node $metadata[$level] $levelpad$message\n",
  level: :error

