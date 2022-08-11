defmodule PrimordialWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      PrimordialWeb.Telemetry,
      # Start the Endpoint (http/https)
      PrimordialWeb.Endpoint
      # Start a worker by calling: PrimordialWeb.Worker.start_link(arg)
      # {PrimordialWeb.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PrimordialWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PrimordialWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
