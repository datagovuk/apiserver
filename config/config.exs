# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :api_server, ApiServer.Endpoint,
  url: [host: "localhost", path: "/data/api"],
  root: Path.dirname(__DIR__),
  secret_key_base:
    "p8zwrvtQEunaM7uXr0ngEjqahd9kSrGmAKxhL+y4ipG5A4DXAYbaBg/gQy6nB1xG",
  render_errors: [accepts: ["html"]],
  pubsub: [name: ApiServer.PubSub,
           adapter: Phoenix.PubSub.PG2],
  server: true


# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]


# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
