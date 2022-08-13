defmodule PrimordialWeb.UserObjects.IdCardComponent do
  use PrimordialWeb, :live_component

  alias PrimordialWeb.UserObjects.IdCardFunctions

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
    <div id="id-card" class="flex flex-row flex-wrap h-[250px] w-full lg:w-[80%] grow border-solid border-y-2 border-x-2 border-[#000] rounded-xl bg-[#E9EEF2] m-auto shadow-black shadow-md h-fit">
     <div class="basis-full bg-[cornflowerblue] text-center text-white lg:tracking-widest uppercase rounded-t-lg p-2">
       <h1>Simulation Supervisor</h1>
     </div>
     <div class="basis-full p-1 ml-1">
       <p class="text-[8px] lg:text-sm font-bold">ID : <%= @user.id_card %></p>
     </div>
       <div id="card-photo" class="avatar bg-avatar-ss mr-[5px]"></div>
       <div class="grow basis-1/5">
         <p class="font-bold text-[8px] lg:text-xl">
         Name : <span class="font-light italic"><%= @user.name %></span>
         </p>
         <p class="font-bold text-[8px] lg:text-xl">
         Sex : <span class="font-light italic">Unknown</span>
         </p>
         <p class="font-bold text-[8px] lg:text-xl">
         Age : <span class="font-light italic">Unknown</span>
         </p>
         <p class="font-bold text-[8px] lg:text-xl">
         SS# : <span class="font-light italic"><%= @user.id %></span>
         </p>
       </div>
       <div class="grow basis-1/5 lg:basis-1/2">
         <p class="font-bold text-[8px] lg:text-[15px]">Functions :</p>
         <p>
         <button type="button" class="btn-primary" phx-click="export" phx-target={@myself}>Export</button>
         </p>
          <%= if @fn_id == :export do %>
             <.live_component module={IdCardFunctions.Export} token={@token} id={@user.id} title={@page_title} />
          <% end %>
       </div>
       <div class="basis-full shadow-inner shadow-blue-400 p-[5px] bg-[#fff] text-[lightsteelblue] italic rounded-b-lg text-center
       portrait:after:content-['(x)[=][#][~][=][#][~][=][#][~](x)']
       landscape:after:content-['(x)[=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~](x)']
       landscape:lg:after:content-['(x)[=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~](x)']">
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
