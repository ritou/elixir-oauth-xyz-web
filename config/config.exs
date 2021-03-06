# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :oauth_xyz,
  namespace: OAuthXYZ,
  ecto_repos: [OAuthXYZ.Repo]

# Configures the endpoint
config :oauth_xyz, OAuthXYZWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "l65kRZm/WzTxI4Cqop9A8PRINkjbaSAje+OcO5IdmWMSWprkknbKsz/OvrSG4PeD",
  render_errors: [view: OAuthXYZWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: OAuthXYZ.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

import_config "user_data.exs"

# For OAuthXYZ.Service.*
config :oauth_xyz, OAuthXYZ.Service.Transaction, data_handler: OAuthXYZ.Sample.DataHandler

# For KittenBlue
config :oauth_xyz, OAuthXYZ.Sample.DataHandler,
  key4transaction: [
    "k4t_2020_001",
    "HS256",
    "qTVOR3jMtu0iKDw1y0wMJsjEsXhO8RirCw9OF84NZPk"
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
