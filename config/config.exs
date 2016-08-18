# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :phamello,
  ecto_repos: [Phamello.Repo]

# Configures the endpoint
config :phamello, Phamello.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WtximjVJudS7HBu9b7F1CXVQkroV4E0/gGXohu0D45EOYr/7R/fQO6xOIF7PJ+ad",
  render_errors: [view: Phamello.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Phamello.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
