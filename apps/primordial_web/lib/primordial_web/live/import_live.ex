defmodule PrimordialWeb.ImportLive do
  use PrimordialWeb, :live_view

  alias Primordial.Accounts.Token
  alias Ecto.Changeset

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="banner">
        <h2><%= @page_title %></h2>
      </div>

      <.form
        :let={f}
        for={@changeset}
        id="token-import-form"
        phx-change="validate"
        phx-submit="import"
      >
        <%= label(f, :token) %>
        <%= text_input(f, :token) %>
        <%= error_tag(f, :token) %>
        <div>
          <%= submit("Import", phx_disable_with: "Saving...", class: "btn-primary mt-2") %>
        </div>
      </.form>
    </div>
    """
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :import, _params) do
    socket
    |> assign(:page_title, "Token import")
    |> assign(:changeset, change_token(%Token{}))
    |> assign(:token, %Token{})
  end

  def change_token(%Token{} = token, param \\ %{}) do
    type = %{token: :string}

    {token, type}
    |> Ecto.Changeset.cast(param, Map.keys(type))
    |> Ecto.Changeset.validate_required(:token)
    |> Ecto.Changeset.validate_length(:token, is: 78, message: "Invalid Token.")
  end

  @impl true
  def handle_event("validate", %{"token" => token_params}, socket) do
    changeset =
      socket.assigns.token
      |> change_token(token_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("import", %{"token" => token_params}, socket) do
    import_token(socket, :import, token_params)
  end

  defp import_token(socket, :import, %{"token" => token}) do
    %{changeset: changeset} = socket.assigns

    case Token.verify(PrimordialWeb.Endpoint, token) do
      {:ok, _user_id} ->
        {:noreply,
         socket
         |> put_flash(:info, "ID card imported successfully")
         |> redirect(to: Routes.session_path(socket, :create, token))}

      {:error, :expired} ->
        changeset =
          Changeset.add_error(changeset, :token, "This Token has expired!")

        {:noreply, assign(socket, :changeset, changeset)}

      {:error, :invalid} ->
        changeset =
          Changeset.add_error(changeset, :token, "There is something wrong with your Token!")

        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  @impl true
  def handle_info({:user_id, user_id, error}, socket),
    do: {:noreply, assign(socket, user_id: user_id, error: error)}
end
