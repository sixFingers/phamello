use Mix.Config

config :phamello, Phamello.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: "example.com", port: 80],
  cache_static_manifest: "priv/static/manifest.json"

config :logger, level: :info

