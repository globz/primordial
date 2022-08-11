defmodule Primordial.Accounts.Token do

  defstruct [:token]

  @type t :: %__MODULE__{
    token: String.t() | nil
  }

  # https://hexdocs.pm/phoenix/Phoenix.Token.html  
  # https://medium.com/@hariroshanmail/authentication-and-authorization-in-phoenix-live-view-5ad677a03ef
  @salt "Ug1QrrCIOKD/JSCBa9pd659jXFJ5kmzWoy+1F51Su0fct3Oyk48lefcXL8h0jyBO"
  @expiry 5 * 7 * 24 * 60 * 60 # Will only be verified if created less than 35 days ago
  
  def sign(conn, data) do
    Phoenix.Token.sign(conn, @salt, data)
  end

  
  def verify(conn, token, opts \\ []) do
    Phoenix.Token.verify(conn, @salt, token, max_age: Keyword.get(opts, :max_age, @expiry))
  end
end
