defmodule PrimordialWeb.Enroll.UserLive.Index do
  use PrimordialWeb, :live_view

  # alias Primordial.Accounts
  alias Primordial.Accounts.User

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :users, %{})}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  # defp apply_action(socket, :edit, %{"id" => id}) do
  #   socket
  #   |> assign(:page_title, "Edit User")
  #   |> assign(:user, Accounts.get_user!(id))
  # end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "Registration form")
    |> assign(:user, %User{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Enroll now!")
    |> assign(:user, nil)
  end

  # @impl true
  # def handle_event("delete", %{"id" => id}, socket) do
  #   user = Accounts.get_user!(id)
  #   {:ok, _} = Accounts.delete_user(user)

  #   {:noreply, assign(socket, :users, list_users())}
  # end

  # defp list_users do
  #   Accounts.list_users()
  # end
end
