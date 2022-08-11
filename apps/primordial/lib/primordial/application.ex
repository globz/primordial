defmodule Primordial.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Primordial.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Primordial.PubSub}
      # Start a worker by calling: Primordial.Worker.start_link(arg)
      # {Primordial.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Primordial.Supervisor)
  end
end
