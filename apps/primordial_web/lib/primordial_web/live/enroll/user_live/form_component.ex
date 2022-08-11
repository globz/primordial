defmodule PrimordialWeb.Enroll.UserLive.FormComponent do
  use PrimordialWeb, :live_component

  alias Primordial.Accounts

  @impl true
  def update(%{user: user} = assigns, socket) do
    changeset = Accounts.change_user(user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.user
      |> Accounts.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.action, user_params)
  end

  # defp save_user(socket, :edit, user_params) do
  #   case Accounts.update_user(socket.assigns.user, user_params) do
  #     {:ok, _user} ->
  #       {:noreply,
  #        socket
  #        |> put_flash(:info, "ID card updated successfully")
  #        |> push_redirect(to: socket.assigns.return_to)}

  #     {:error, %Ecto.Changeset{} = changeset} ->
  #       {:noreply, assign(socket, :changeset, changeset)}
  #   end
  # end

  defp save_user(socket, :new, name) do

    user_params = Map.put(name, "id_card", make_id_card())
    IO.inspect(user_params)

    case Accounts.create_user(user_params) do
      {:ok, user} ->
        IO.inspect(user)
        token = Accounts.Token.sign(PrimordialWeb.Endpoint, user.id)
        IO.inspect(socket)
        {:noreply,
         socket
         |> put_flash(:info, "ID card created successfully")
         |> redirect(to: Routes.session_path(socket, :create, token))}
                    
      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp make_id_card do
    << i1 :: unsigned-integer-32, i2 :: unsigned-integer-32, i3 :: unsigned-integer-32>> = :crypto.strong_rand_bytes(12)
    :rand.seed(:exsplus, {i1, i2, i3})
    :rand.uniform(10000)
  end
  
end
