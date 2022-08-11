# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of the Config module.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
import Config

config :primordial_web, Primordial_web.Repo,
  database: "primordial_web_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :primordial, Primordial.Repo,
  database: "primordial_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

# Configure Mix tasks and generators
config :primordial,
  ecto_repos: [Primordial.Repo]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :primordial, Primordial.Mailer, adapter: Swoosh.Adapters.Local

# Swoosh API client is needed for adapters other than SMTP.
config :swoosh, :api_client, false

config :primordial_web,
  ecto_repos: [Primordial.Repo],
  generators: [context_app: :primordial]

# Configures the endpoint
config :primordial_web, PrimordialWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: PrimordialWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Primordial.PubSub,
  live_view: [signing_salt: "JhiZwuRt"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../apps/primordial_web/assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure live_reload backend to polls the filesystem
# instead of using inotify
# https://github.com/phoenixframework/phoenix_live_reload
config :phoenix_live_reload,
  backend: :fs_poll

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configures Tailwind CSS
config :tailwind, version: "3.1.6", default: [
  args: ~w(
    --config=tailwind.config.js
    --input=css/app.css
    --output=../priv/static/assets/app.css
  ),
  cd: Path.expand("../apps/primordial_web/assets", __DIR__)
]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
