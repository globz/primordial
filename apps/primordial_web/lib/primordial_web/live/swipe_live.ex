defmodule PrimordialWeb.SwipeLive do
  use PrimordialWeb, :live_view

  alias Primordial.Accounts
  # action={@live_action}
  @impl true
  def render(assigns) do
    ~H"""
    <%= if @view_to_show == :swipe_animation do %>
      <.live_component
        module={PrimordialWeb.Animations.SwipeAnimationComponent}
        id="swipe-animation-component"
        reader_state={@reader_state}
      />
    <% end %>
    <%= if @view_to_show == :authenticated do %>
      <.live_component
        module={PrimordialWeb.UserObjects.IdCardComponent}
        id={@user.id}
        user={@user}
        token={@token}
        context={@context}
      />
    <% end %>
    <%= if @view_to_show == :error do %>
      If you previously exported your authentication Token, you may
      <.link href={~p"/import"} class={["underline underline-offset-8"]}>import</.link>
      it or <.link href={~p"/enroll/users"} class={["underline underline-offset-8"]}>enroll</.link>
      now.
    <% end %>
    """
  end

  @impl true
  def mount(_params, %{"token" => token}, socket) do
    case Accounts.Token.verify(PrimordialWeb.Endpoint, token) do
      {:ok, user_id} ->
        {:ok,
         assign(socket,
           user: Accounts.get_user!(user_id),
           token: token,
           view_to_show: :swipe_animation,
           reader_state: :valid,
           context: :swipe
         )}

      {:error, :expired} ->
        {:ok,
         assign(socket,
           error: "This ID card has expired!",
           view_to_show: :swipe_animation,
           reader_state: :invalid
         )}

      # {:ok, assign(socket, error: "This ID card has expired!", view_to_show: :error)}

      {:error, :invalid} ->
        {:ok,
         assign(socket,
           error: "There is something wrong with your ID card!",
           view_to_show: :swipe_animation,
           reader_state: :invalid
         )}

        # {:ok, assign(socket, error: "There is something wrong with your ID card!", view_to_show: :error)}
    end
  end

  def mount(_params, %{}, socket) do
    {:ok,
     assign(socket,
       error: "You do not own an ID card, you must enroll first.",
       view_to_show: :swipe_animation,
       reader_state: :invalid
     )}

    # {:ok, assign(socket, error: "You do not own an ID card, you must enroll first.", view_to_show: :error)}
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

  @impl true
  def handle_info(:swipe_accepted, socket) do
    {:noreply, assign(socket, view_to_show: :authenticated)}
  end

  @impl true
  def handle_info(:swipe_denied, socket) do
    {:noreply, assign(socket, view_to_show: :error)}
  end
end
