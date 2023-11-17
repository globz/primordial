defmodule Mix.Tasks.Psql.Start do
  @moduledoc "Start psql instance"
  @shortdoc "Start psql instance"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.shell().cmd("pg_ctl start")
  end
end
