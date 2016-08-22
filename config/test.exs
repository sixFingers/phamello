use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :phamello, Phamello.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :phamello, Phamello.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "phamello_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :phamello, Phamello.Picture,
  storage_path: "fixture/storage",
  max_file_size: 200_000

import_config "test.secret.exs"
