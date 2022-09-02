defmodule PrimordialWeb.SoupComponents.AppDrawer do
  use PrimordialWeb, :live_component
  
  @impl true
  def render(assigns) do
    ~H"""
     <div id="app-drawer">
      <.soup_app_drawer>
       <h2 class="pb-2"><%= @app_title %></h2>
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
