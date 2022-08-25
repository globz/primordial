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
  def mount(_params, %{"token" => token}, socket) do
    case Accounts.Token.verify(PrimordialWeb.Endpoint, token) do
      {:ok, user_id} ->
        {:ok, assign(socket,
            user: Accounts.get_user!(user_id),
            token: token)}    

      {:error, :expired} ->
        {:ok, assign(socket, error: "This ID card has expired!")}

      {:error, :invalid} ->
        {:ok, assign(socket, error: "There is something wrong with your ID card!")}        
    end
  end

  def mount(_params, %{}, socket) do    
    {:ok, assign(socket, error: "You do not own an ID card, you must enroll first.")}    
  end  

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :sign_in, _params) do    
    case socket.assigns do
      %{error: error} ->
        put_flash(socket, :error, "#{error}")

      _ ->        
        put_flash(socket, :info, "Authentication successful!")
    end
  end

  @impl true
  def handle_info({:user_id, user_id}, socket),
    do: {:noreply, assign(socket, user_id: user_id)}  
end
