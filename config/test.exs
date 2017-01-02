use Mix.Config

#-------------------------------
#  WORKFLOW
#-------------------------------


config :workflow,
  adapter: Workflow.Extreme.Adapter

#-------------------------------
#  EXTREME [Eventstore Driver]
#-------------------------------


config :extreme, :event_store,
  db_type: :node,
  host: "localhost",
  port: 1113,
  username: "admin",
  password: "changeit",
  reconnect_delay: 2_000,
  max_attempts: :infinity


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
    metadata: [:module, :function, :id, :uuid],
    level: :info

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

#-------------------------------
#  TEST WATCH
#-------------------------------


# see https://github.com/lpil/mix-test.watch how 
# to exclude folders and files
# config :mix_test_watch,
# 	clear: true,     # clean the console
#   tasks: [
#   	"test"
#     #"dogma"
# ]

