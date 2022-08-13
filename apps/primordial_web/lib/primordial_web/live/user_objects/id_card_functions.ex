defmodule PrimordialWeb.UserObjects.IdCardFunctions.Export do
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
      <h2 class="basis-full pb-2"><%= @title %></h2>
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
      <pre class="basis-full relative text-ellipsis overflow-hidden text-sm md:text-[15px] font-bold bg-[floralwhite]">
      <.clipboard_button copy_from={@copy_from} />
      <br>
      <code id="token-secret" class="text-red-600"><%= @token %></code>
      </pre>
     </.id_card_fn_modal>
    </div>
    """
  end  
end

defmodule PrimordialWeb.UserObjects.IdCardFunctions.Show do
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
