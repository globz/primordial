defmodule PrimordialWeb.UserObjects.Private.IdCardFunctions.Export do
  use PrimordialWeb, :live_component

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:copy_from, "#token-secret")}     
  end    
  
  @impl true
  def render(assigns) do
    ~H"""
    <div>
     <.id_card_fn_modal>
      <h2><%= @title %></h2>
      <p class="alert alert-info" role="alert">
      The following Token is a secret string which authenticate you with the
      Primordial Simulation Project.
      <br>
      Copy and store this Token in a text document for future reference.
      <br>
      You may import this Token to another device or browser.
      </p>
      <pre>
      <.clipboard_button copy_from={@copy_from} />
      <code id="token-secret"><%= @token %></code>
      </pre>
     </.id_card_fn_modal>
    </div>
    """
  end  
end

defmodule PrimordialWeb.UserObjects.Private.IdCardFunctions.Show do
  use PrimordialWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
     <.id_card_fn_modal>
      <h2><%= @title %></h2>
     </.id_card_fn_modal>
    </div>
    """
  end  
end
