use Mix.Config

config :phamello, Phamello.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: "gentle-wildwood-53699.herokuapp.com", port: 443],
  force_ssl: [rewrite_on: [:x_forwarded_proto]]

config :phamello, Phamello.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
  ssl: true

config :logger, level: :info

