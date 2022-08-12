defmodule PrimordialWeb.UserObjects.Private.IdCardComponent do
  use PrimordialWeb, :live_component

  alias PrimordialWeb.UserObjects.Private.IdCardFunctions

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:fn_id, :none)}     
  end
  
  @impl true
  def render(assigns) do
    ~H"""
      <div id="id-card" class="border-solid border-y-2 border-x-2 border-[#000] rounded-xl bg-[#E9EEF2] m-auto shadow-black shadow-md">
        <div class="bg-[cornflowerblue] text-center text-white tracking-widest uppercase rounded-t-lg p-2">
          <h1>Simulation Supervisor</h1>
        </div>
        <div class="flex p-1">
          <div class="ml-1">
            <p class="text-sm font-bold">ID : <%= @user.id_card %></p>
          </div>
        </div>
        <div class="flex p-1.5">
          <div id="card-photo" 
          class="rounded-xl bg-avatar-ss w-[195px] h-[180px] bg-center bg-no-repeat bg-contain border-solid border-2 border-white mr-[20px]"></div>
          <div clas="flex">
            <div class="mr-2">
              <p class="font-bold text-xl">
              Name : <span class="text-md font-light italic"><%= @user.name %></span>
              </p>                                        
              <div class="mr-2">
                <p class="font-bold text-xl">
                Sex : <span class="text-md font-light italic">Unknown</span>
                </p>                
              </div>
              <div class="mr-2">
                <p class="font-bold text-xl">
                Age : <span class="text-md font-light italic">Unknown</span>
                </p>
              </div>
              <div class="mr-2">
                <p class="font-bold text-xl">
                SS# : <span class="text-md font-light italic"><%= @user.id %></span>
                </p>
              </div>
            </div>
            <div class="mt-2">
              <p class="font-bold text-[15px]">Functions :</p>
              <p>
              <button type="button" class="btn-primary" phx-click="export" phx-target={@myself}>Export</button>
              </p>
               <%= if @fn_id == :export do %>
                  <.live_component module={IdCardFunctions.Export} token={@token} id={@user.id} title={@page_title} />
               <% end %>
            </div>
          </div>
        </div>
        <div id="card-code" class="shadow-inner shadow-blue-400">
          (x)[=][#][~][#][~][#][~][#][~][#][~][#][~][#][~][#][~][#][~][#][~][#][~][#][~][#][~][=](x)(*)
        </div>
      </div>
    """
  end

  @impl true
  def handle_event("export", _assigns, socket) do    
    IO.inspect(socket)    
    {:noreply, assign(socket, fn_id: :export, page_title: "fn_id: :export")}
  end

  @impl true
  def handle_event("close", _assigns, socket) do
    {:noreply, assign(socket, :fn_id, :none)}
  end  
end
