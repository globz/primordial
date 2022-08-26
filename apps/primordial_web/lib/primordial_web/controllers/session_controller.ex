defmodule PrimordialWeb.SessionController do
  use PrimordialWeb, :controller

  alias Primordial.Accounts

  # Create and update session state based on the following parameters:
  # conn & params
  
  def login(conn, user_id, remember_me \\ false) do
    conn
    |> put_session(:token, Accounts.Token.sign(conn, user_id))
    |> put_session(:remember_me, remember_me)
    |> put_session(:live_socket_id, "users_socket:#{user_id}")
    |> put_session(:user_id, user_id)
    |> put_session(:soup_state, "offline")
    |> configure_session(renew: true)
  end

  def update_soup_state(conn, %{"state" => state}) do
    case String.match?(List.to_string(get_req_header(conn, "referer")),
          ~r/swipe$/) && state == "online" do
      true ->
        conn
        |> put_session(:soup_state, state)
        |> IO.inspect
        |> redirect(to: Routes.soup_path(conn, :sign_in))
      false ->
        redirect(conn, to: Routes.page_path(conn, :index))
    end
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
