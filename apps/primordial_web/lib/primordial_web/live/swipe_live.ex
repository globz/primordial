defmodule PrimordialWeb.SwipeLive do
  use PrimordialWeb, :live_view

  alias Primordial.Accounts

  @impl true
  def render(assigns) do
    ~H"""
      <%= if @view_to_show == :authenticated do %>
           <.live_component
             module={PrimordialWeb.UserObjects.IdCardComponent}
             id={@user.id}
             action={@live_action}
             user={@user}
             token={@token}
             context={@context}
           />
      <% else %>
        If you previously exported your authentication Token, you may
         <%= live_redirect "import", to: Routes.import_path(@socket, :import) %>
        it or
        <%= live_redirect "enroll", to: Routes.enroll_user_index_path(@socket, :new) %>
        now.
      <% end %>
    """
  end
  
  @impl true
  def mount(_params, %{"token" => token}, socket) do
    case Accounts.Token.verify(PrimordialWeb.Endpoint, token) do
      {:ok, user_id} ->
        {:ok, assign(socket,
            user: Accounts.get_user!(user_id),
            token: token,
            view_to_show: :authenticated,
            context: :swipe)}

      {:error, :expired} ->
        {:ok, assign(socket, error: "This ID card has expired!", view_to_show: :error)}

      {:error, :invalid} ->
        {:ok, assign(socket, error: "There is something wrong with your ID card!", view_to_show: :error)}
    end
  end

  def mount(_params, %{}, socket) do    
    {:ok, assign(socket, error: "You do not own an ID card, you must enroll first.", view_to_show: :error)}
  end  

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :authenticate, _params) do
    case socket.assigns do
      %{error: error} ->
        put_flash(socket, :error, "#{error}")

      _ ->
        put_flash(socket, :info, "Authentication successful!")
    end
  end
end
