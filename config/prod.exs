use Mix.Config

config :phamello, Phamello.Endpoint,
  url: [scheme: "https", host: "mysterious-meadow-6277.herokuapp.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]]

config :hello_phoenix, HelloPhoenix.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true

config :logger, level: :info

