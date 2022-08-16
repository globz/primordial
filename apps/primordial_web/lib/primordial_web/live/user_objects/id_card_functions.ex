defmodule PrimordialWeb.UserObjects.IdCardFunctions.Context do
  use PrimordialWeb, :live_component
  alias PrimordialWeb.UserObjects.IdCardFunctions
  
  @impl true
  def render(assigns) do
    ~H"""
    <div id="fn-context">
      <%= if @context == :swipe do %>     
       <p>
        <button type="button" class="btn-primary" phx-click="export" phx-target="#id-card">Export</button>
        <button type="button" class="btn-primary" phx-click="boot-up" phx-target="#id-card">Boot up</button>
         <%= if @fn_id == :export do %>
           <.live_component module={IdCardFunctions.Export} token={@token} id={@user.id} title={@page_title} />
         <% end %>
         <%= if @fn_id == :boot_up do %>
           <.live_component module={IdCardFunctions.BootUp} token={@token} id={@user.id} title={@page_title} />
         <% end %>
       </p>
      <% end %>
    </div>
    """
  end
end

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
      <pre class="group basis-full relative text-ellipsis overflow-hidden text-sm md:text-[15px] font-bold bg-[floralwhite]">
      <.clipboard_button copy_from={@copy_from} />
      <br>
      <code id="token-secret" class="text-red-600"><%= @token %></code>
      </pre>
     </.id_card_fn_modal>
    </div>
    """
  end
end

defmodule PrimordialWeb.UserObjects.IdCardFunctions.BootUp do
  use PrimordialWeb, :live_component
  
  @impl true
  def render(assigns) do
    ~H"""
    <div>
     <.id_card_fn_modal>
      <h2 class="basis-full pb-2"><%= @title %></h2>
      <%= for step <- boot_seq do %>
       <p class="text-bold text-orange-500 basis-full pb-2"><%= step %></p>
       <br>
      <% end %>
      <p class="text-green-500 basis-full pb-2">Booting sequence complete.</p>
      <p class="basis-full pb-2"><%= live_patch "[Sign-in]", to: Routes.enroll_user_index_path(@socket, :new) %></p>
     </.id_card_fn_modal>
    </div>
    """
  end

  def boot_seq() do
    steps = [{Enum.random(1..5), "Initializing OS..."},
             {Enum.random(1..7), "Allocating memory..."},
             {Enum.random(1..3), "Calculating..."},
             {Enum.random(1..2), "Insufficient memory..."},
             {Enum.random(1..4), "Rebooting..."},
             {Enum.random(1..2), "User profile corrupted..."},
             {Enum.random(1..2), "Restoring session from backup..."}]
    
    steps
      |> Enum.map(fn ({weight, step}) -> 
      List.duplicate(step, weight)
    end)
    |> Enum.take_random(2)
    |> List.flatten
  end  
end
