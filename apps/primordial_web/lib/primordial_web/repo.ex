defmodule Primordial_web.Repo do
  use Ecto.Repo,
    otp_app: :primordial_web,
    adapter: Ecto.Adapters.Postgres
end
