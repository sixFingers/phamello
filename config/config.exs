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

config :phamello, Phamello.GithubClient,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

config :guardian, Guardian,
  issuer: "Phamello",
  ttl: {30, :days},
  secret_key: System.get_env("GUARDIAN_SECRET_KEY"),
  serializer: Phamello.GuardianSerializer

config :phamello, Phamello.Picture,
  storage_path: System.get_env("IMAGE_STORAGE_FOLDER"),
  max_file_size: 5_000_000

config :phamello, :s3_client,
  aws_access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  aws_secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
  bucket_name: System.get_env("IMAGE_STORAGE_BUCKET")

config :phamello, Phamello.S3Client,
  aws_access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
  aws_secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
  bucket_name: System.get_env("IMAGE_STORAGE_BUCKET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
