defmodule PrimordialWeb.SoupComponents.AppDrawer do
  use PrimordialWeb, :live_component
  
  @impl true
  def render(assigns) do
    ~H"""
     <div id="app-drawer">
      <.soup_app_drawer>
       <h2 class="basis-full pb-2"><%= @app_title %></h2>
       <div class="basis-full alert alert-info text-center md:text-left font-semibold" role="alert">
        <p>
        The following Token is a secret string which authenticate you with the
        Primordial Simulation Project.
        </p>
        <p>
        Copy and store this Token in a text document for future reference.
        </p>
        <p>
        You may import this Token to another device or browser.
        </p>
       </div>
       <code id="token-secret" class="text-red-600"><%= @token %></code>
      </.soup_app_drawer>
     </div>
    """
  end

  @impl true
  def handle_event("close", _assigns, socket) do
    send self(), {:drawer_id, :none}
    {:noreply, socket}
  end

  def handle_event("close_with_key", %{"key" => "Escape"}, socket) do
    send self(), {:drawer_id, :none}
    {:noreply, socket}
  end

  def handle_event("close_with_key", _, socket) do
    send self(), {:drawer_id, :none}
    {:noreply, socket}
  end    
  
end
