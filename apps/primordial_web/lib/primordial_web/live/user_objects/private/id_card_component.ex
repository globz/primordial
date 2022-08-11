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
      <div id="id-card">
        <div id="card-title">
          <h1 id="title">Simulation Supervisor</h1>
        </div>
        <div id="card-id">
          <div id="card-number">
            <p class="info">ID : <%= @user.id_card %></p>
          </div>
          <p class="header-info"></p>
        </div>
        <div id="card-information">
          <div id="card-photo"></div>
          <div id="card-text">
            <div id="card-name">
              <div class="card-box"></div>
              <p class="info">Name :</p>
              <p><%= @user.name %></p>
            </div>
            <div id="card-detail">
              <div class="card-box">
                <p class="info">Sex :</p>
                <p>M</p>
              </div>
              <div class="card-box">
                <p class="info">Age :</p>
                <p>33</p>
              </div>
              <div class="card-box">
                <p class="info">SS# : </p>
                <p><%= @user.id %></p>
              </div>
            </div>
            <div id="card-functions">
              <div class="card-box"></div>
              <p class="info">Functions :</p>
              <p><button type="button" class="btn-primary" phx-click="export" phx-target={@myself}>Export</button></p>
               <%= if @fn_id == :export do %>
                  <.live_component module={IdCardFunctions.Export} token={@token} id={@user.id} title={@page_title} />
               <% end %>
            </div>
          </div>
        </div>
        <div id="card-code">
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
