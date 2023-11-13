defmodule PrimordialWeb.MixProject do
  use Mix.Project

  def project do
    [
      app: :primordial_web,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {PrimordialWeb.Application, []},
      extra_applications: [:logger, :runtime_tools, :phoenix]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.7.10"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_html, "~> 3.3.3"},
      {:phoenix_live_reload, "~> 1.4.1", only: :dev},
      {:phoenix_live_view, "~> 0.20.1"},
      {:phoenix_view, "~> 2.0.3"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.6.0", runtime: Mix.env() == :dev},
      {:telemetry_metrics, "~> 0.6.1"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20.0"},
      {:primordial, in_umbrella: true},
      {:jason, "~> 1.4.0"},
      {:plug_cowboy, "~> 2.6.0"},
      {:ecto_psql_extras, "~> 0.7.14"},
      {:tailwind, "~> 0.2.2", runtime: Mix.env() == :dev}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "tailwind.install", "esbuild.install"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"],
      "assets.reset": ["phx.digest.clean --all"],
      "assets.build": ["esbuild default", "tailwind default"]
    ]
  end
end
