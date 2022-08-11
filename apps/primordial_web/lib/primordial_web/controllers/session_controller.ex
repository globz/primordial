defmodule PrimordialWeb.SessionController do
  use PrimordialWeb, :controller

  alias Primordial.Accounts
  
  def login(conn, user_id, remember_me \\ false) do
    conn
    |> put_session(:token, Accounts.Token.sign(conn, user_id))
    |> put_session(:remember_me, remember_me)
    |> put_session(:live_socket_id, "users_socket:#{user_id}")
    |> put_session(:user_id, user_id)
    |> configure_session(renew: true)
  end


  def create(conn, %{"token" => token} = params) do
    case Accounts.Token.verify(PrimordialWeb.Endpoint, token) do
      {:ok, user_id} ->
        conn
        |> login(user_id)
        |> IO.inspect
        |> redirect(to: Routes.page_path(conn, :index))
        
      _ -> create(conn, params)
    end
  end

  def create(conn, _params) do
    conn
    |> put_flash(:error, "error")
    |> redirect(to: Routes.page_path(conn, :index))
  end

end
