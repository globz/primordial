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
        <button type="button" class="btn-primary" phx-click="boot_up" phx-target="#id-card">Boot up</button>
         <%= if @fn_id == :export do %>
           <.live_component 
           module={IdCardFunctions.Export} 
           token={@token} 
           id={@user.id}  
           title={@page_title} />
         <% end %>
         <%= if @fn_id == :boot_up do %>
           <.live_component
           module={IdCardFunctions.BootUp}
           token={@token} id={@user.id}
           title={@page_title} />
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
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:soup_os_state, :offline)
     |> assign(:seq, boot_seq())}
  end
  
  @impl true
  def render(assigns) do
    # IO.inspect(assigns)
    # Enum.member?(assigns.seq, "Soup OS Ready.")
    # assigns = update(assigns, :soup_os_state, fn _state -> :online end)
    # IO.inspect(assigns.seq)
    # IO.inspect(assigns)

    #<%= for step <- boot_seq() do %>    
    ~H"""
    <div>
     <.id_card_fn_modal>
      <h2 class="basis-full pb-2">
      <%= @title %> <span class="text-red-500">[alpha]</span>
      </h2>
      <div class="bg-black rounded w-full p-2">
      <%= for step <- @seq do %>    
       <p class="text-bold text-orange-600 basis-full pb-2"><%= step %></p>
       <%= if step == "Soup OS Ready." do %>
       <br>
       <p class="text-green-500 basis-full pb-2">Booting sequence complete.</p>
       <p class="text-green-500 basis-full pb-2">You may now taste the
       Primordial <%= live_redirect "[Soup]", to: Routes.soup_path(@socket, :sign_in) %></p>
       <div id="card-photo" class="mt-2 avatar bg-avatar-soup-os mr-[5px]"></div>       
       <% end %>       

      <% end %>
      </div>
     </.id_card_fn_modal>
    </div>
    """    
  end

  def boot_seq() do

    # assigns = update(assigns, :soup_os_state, fn _state -> :online end)
    # IO.inspect(assigns)
    
    steps = [[message: "Loading BIOS...", weight: Enum.random(1..5)],
             [message: "POST...", weight: Enum.random(1..5)],
             [message: "Initializing first-stage boot loader...", weight: Enum.random(1..3)],
             [message: "Chain loading boot loaders...", weight: Enum.random(1..3)],
             [message: "Calculating...", weight: Enum.random(1..3)],
             [message: "Allocating memory...", weight: Enum.random(1..6)],
             [message: "Initializing OS...", weight: Enum.random(1..5)],
             [message: "Insufficient memory...", weight: Enum.random(1..2)],
             [message: "Rebooting...", weight: Enum.random(1..4)],
             [message: "Loading System Configuration...", weight: Enum.random(1..3)],
             [message: "Loading System Utilities...", weight: Enum.random(1..3)],
             [message: "Loading User Session...", weight: Enum.random(1..3)],
             [message: "User Profile corrupted...", weight: Enum.random(1..3)],
             [message: "Restoring User Profile from backup...", weight: Enum.random(1..2)],
             [message: "Soup OS Ready.", weight: Enum.random(1..1)]]

    # Weighted and ranked steps
    weigthed_ranked_steps = Enum.zip([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15], steps |> Enum.map(fn step -> List.duplicate(step[:message], step[:weight]) end))

    # Random selection of weigthed_ranked_steps
    Enum.take_random(weigthed_ranked_steps
    |> Enum.map(fn {rank, message} ->
        {[rank, Enum.take_random(message, 15)]} end), 5)     
        |> List.keysort(0)
        |> Enum.map(fn {[_rank, message]} -> message end)
        |> List.flatten
  end
end
