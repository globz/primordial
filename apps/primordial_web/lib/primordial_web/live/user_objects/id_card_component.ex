defmodule PrimordialWeb.UserObjects.IdCardComponent do
  use PrimordialWeb, :live_component

  alias PrimordialWeb.UserObjects.IdCardFunctions

  @impl true
  def update(assigns, socket) do
    IO.inspect(assigns)
    {:ok,
     socket
     |> assign(assigns)
     |> assign(fn_id: :none, page_title: "")}
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
         <p class="font-bold text-[8px] md:text-sm xl:text-xl">
         [Name]
         </p>
         <span class="font-bold text-[8px] md:text-sm xl:text-xl font-light italic"><%= @user.name %></span>
         <p class="font-bold text-[8px] md:text-sm xl:text-xl">
         [Title] <span class="font-light italic">Assistant</span>
         </p>
         <p class="font-bold text-[8px] md:text-sm xl:text-xl">
         [Profession] <span class="font-light italic">None</span>
         </p>
         <p class="font-bold text-[8px] md:text-sm xl:text-xl">
         [SS#] <span class="font-light italic"><%= @user.id %></span>
         </p>
       </div>
       <div class="grow basis-1/5 lg:basis-1/2">
         <p class="font-bold text-[8px] lg:text-[15px]">Functions :</p>
         <.live_component 
           module={IdCardFunctions.Context} 
           token={@token} 
           fn_id={@fn_id} 
           id={@user.id} 
           user={@user} 
           context={@context} 
           page_title={@page_title} />
       </div>
       <div class="basis-full shadow-inner shadow-blue-400 p-[5px] bg-[#fff] text-[lightsteelblue] italic rounded-b-lg text-center
       portrait:after:content-['(x)[=][#][~][=][#][~][=][#][~](x)']
       landscape:md:after:content-['(x)[=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~](x)']
       landscape:lg:after:content-['(x)[=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~](x)']
       landscape:xl:after:content-['(x)[=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~][=][#][~](x)']">
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
  def handle_event("boot_up", _assigns, socket) do    
    IO.inspect(socket)    
    {:noreply, assign(socket, fn_id: :boot_up, page_title: "fn_id: :boot_up")}
  end  

  @impl true
  def handle_event("close", _assigns, socket) do
    {:noreply, assign(socket, :fn_id, :none)}
  end

  def handle_event("close_with_key", %{"key" => "Escape"}, socket) do
    {:noreply, assign(socket, :fn_id, :none)}
  end

  def handle_event("close_with_key", _, socket) do
    {:noreply, socket}
  end
end
