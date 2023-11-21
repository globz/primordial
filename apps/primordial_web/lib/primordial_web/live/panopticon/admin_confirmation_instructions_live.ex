defmodule PrimordialWeb.AdminConfirmationInstructionsLive do
  use PrimordialWeb, :live_view

  alias Primordial.Admins

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        No confirmation instructions received?
        <:subtitle>We'll send a new confirmation link to the specified inbox</:subtitle>
      </.header>

      <.simple_form for={@form} id="resend_confirmation_form" phx-submit="send_instructions">
        <.input field={@form[:email]} type="email" placeholder="Email" required />
        <:actions>
          <.button phx-disable-with="Sending..." class="w-full">
            Resend confirmation instructions
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "admin"))}
  end

  def handle_event("send_instructions", %{"admin" => %{"email" => email}}, socket) do
    if admin = Admins.get_admin_by_email(email) do
      Admins.deliver_admin_confirmation_instructions(
        admin,
        &url(~p"/panopticon/confirm/#{&1}")
      )
    end

    info =
      "If the email is in our system and it has not been confirmed yet, the recipient will receive an email with instructions shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> redirect(to: ~p"/")}
  end
end
