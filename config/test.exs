use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :oauth_xyz, OAuthXYZWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :oauth_xyz, OAuthXYZ.Repo,
  adapter: Ecto.Adapters.MySQL,
  username: "root",
  password: "",
  database: "oauth_xyz_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

# For OAuthXYZ.Service.*
config :oauth_xyz, OAuthXYZ.Service.Transaction, data_handler: OAuthXYZWeb.Test.DataHandler
