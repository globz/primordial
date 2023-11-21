defmodule PrimordialWeb.AdminForgotPasswordLive do
  use PrimordialWeb, :live_view

  alias Primordial.Admins

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Reset Admin Password
        <:subtitle>We'll send a password reset link to the specified inbox</:subtitle>
      </.header>

      <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Sending..." class="w-full">
            Send password reset instructions
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "admin"))}
  end

  def handle_event("send_email", %{"admin" => %{"email" => email}}, socket) do
    if admin = Admins.get_admin_by_email(email) do
      Admins.deliver_admin_reset_password_instructions(
        admin,
        &url(~p"/panopticon/reset_password/#{&1}")
      )
    end

    info =
      "If the email is in our system, the administrator will receive instructions to reset the password shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
