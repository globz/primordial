defmodule Primordial.Repo do
  use Ecto.Repo,
    otp_app: :primordial,
    adapter: Ecto.Adapters.Postgres
end
