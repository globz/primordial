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
      {Phoenix.PubSub, name: Primordial.PubSub},
      # Start the Primordial PubSub registry system
      {Registry, keys: :duplicate, name: Primordial.Registry.PubSub},
      # Start the Primordial AsyncRegistry system
      Primordial.AsyncRegistry,
      # Start poolboy :python_worker
      :poolboy.child_spec(:worker, python_poolboy_config())
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: Primordial.Supervisor)
  end

  defp python_poolboy_config do
    [
      {:name, {:local, :python_worker}},
      {:worker_module, Primordial.PythonWorker},
      {:size, 5},
      {:max_overflow, 0}
    ]
  end  
end
