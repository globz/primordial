defmodule PrimordialWeb.SoupLive do
  use PrimordialWeb, :live_view

  alias Primordial.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    Soup OS.
    """
  end
  
  @impl true
  def mount(_params, %{"token" => token, "soup_state" => state} = session, socket) do        
    case Accounts.Token.verify(PrimordialWeb.Endpoint, token) do
      {:ok, user_id} ->
        {:ok, assign(socket,
            user: Accounts.get_user!(user_id),
            token: token,
            soup_state: state)}

      {:error, :expired} ->
        {:ok, assign(socket, error: "This ID card has expired!")}

      {:error, :invalid} ->
        {:ok, assign(socket, error: "There is something wrong with your ID card!")}
    end
  end

  def mount(_params, %{}, socket) do
    {:ok, assign(socket, error: "You do not own an ID card, you must enroll first.")}
  end

  defp check_soup_state(socket, state) do
    case state == "online" do
      true ->
        put_flash(socket, :info, "Welcome to Soup OS!")        

      false ->
        socket
        |> put_flash(:error, "You must first boot up Soup OS!")
        |> redirect(to: Routes.page_path(socket, :index))
    end
  end
  
  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :sign_in, _params) do    
    case socket.assigns do
      %{error: error} ->
        socket
        |> put_flash(:error, "#{error}")        
        |> redirect(to: Routes.page_path(socket, :index))

      _ ->
        Process.send_after(self(), :clear_flash, 5000)
        check_soup_state(socket, socket.assigns.soup_state)
    end
  end

  @impl true
  def handle_info({:user_id, user_id}, socket),
    do: {:noreply, assign(socket, user_id: user_id)}

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
