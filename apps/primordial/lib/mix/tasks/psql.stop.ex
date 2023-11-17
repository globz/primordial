defmodule Mix.Tasks.Psql.Stop do
  @moduledoc "Stop psql instance"
  @shortdoc "Stop psql instance"

  use Mix.Task

  @impl Mix.Task
  def run(_args) do
    Mix.shell().cmd("pg_ctl stop")
  end
end
