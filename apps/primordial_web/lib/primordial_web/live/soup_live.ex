defmodule PrimordialWeb.SoupLive do
  use PrimordialWeb, :live_view 
  
  alias Primordial.Accounts

    # <%= if Enum.member?([:id_card_app, :entangle_app], @drawer_id) do %>
    # <.live_component 
    # module={Soup.App.Drawer} 
    # token={@token}
    # id={@user.id}  
    # title={@page_title} />
    # <% end %>
  
  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-row grow basis-1/5 lg:basis-1/2 p-2 ml-1 pt-16
    self-center justify-center">
     <button id="os-icon" class="flex soup-os-icon bg-id-card-icon mr-[5px]" phx-click="id-card-app"></button>
     <button id="os-icon" class="flex soup-os-icon bg-entangle-icon mr-[5px]" phx-click="entangle-app"></button>
     <button id="os-icon" class="flex soup-os-icon bg-agi-icon bg-black mr-[5px]" phx-click="agi-app"></button>
     <button id="os-icon" class="flex soup-os-icon bg-simulation-icon mr-[5px]" phx-click="simulation-app"></button>
    </div>
    <div class="flex flex-row grow basis-1/5 lg:basis-1/2 p-2 ml-1 pt-2 self-center justify-center">
     <button id="os-icon" class="flex soup-os-icon bg-jobs-icon mr-[5px]" phx-click="jobs-app"></button>
     <button id="os-icon" class="flex soup-os-icon bg-profession-icon mr-[5px]" phx-click="profession-app"></button>
     <button id="os-icon" class="flex soup-os-icon bg-system-state-icon bg-black mr-[5px]" phx-click="system-state-app"></button>
     <button id="os-icon" class="flex soup-os-icon bg-democratic-results-icon mr-[5px]" phx-click="democratic-app"></button>
    </div>
    """
  end
  
  @impl true
  def mount(_params, %{"token" => token, "soup_state" => state}, socket) do        
    case Accounts.Token.verify(PrimordialWeb.Endpoint, token) do
      {:ok, user_id} ->
        socket = assign(socket,
        user: Accounts.get_user!(user_id),
        token: token,
        soup_state: state,
        bg: select_bg(),
        drawer_id: :none)
        {:ok, socket, layout: {PrimordialWeb.LayoutView, "soup.html"}}
        
      {:error, :expired} ->
        {:ok, assign(socket, error: "This ID card has expired!")}

      {:error, :invalid} ->
        {:ok, assign(socket, error: "There is something wrong with your ID card!")}
    end
  end

  def mount(_params, %{}, socket) do
    {:ok, assign(socket, error: "You do not own an ID card, you must enroll first.")}
  end

  defp check_soup_state(socket, state) do
    case state == "online" do
      true ->
        put_flash(socket, :info, "Welcome to Soup OS!")        

      false ->
        socket
        |> put_flash(:error, "You must first boot up Soup OS!")
        |> redirect(to: Routes.page_path(socket, :index))
    end
  end
  
  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :sign_in, _params) do    
    case socket.assigns do
      %{error: error} ->
        socket
        |> put_flash(:error, "#{error}")        
        |> redirect(to: Routes.page_path(socket, :index))

      _ ->
        Process.send_after(self(), :clear_flash, 5000)
        check_soup_state(socket, socket.assigns.soup_state)
    end
  end

  defp select_bg() do
    bg = [
      "bg-soup-os-bg-1",
      "bg-soup-os-bg-2",
      "bg-soup-os-bg-3",
      "bg-soup-os-bg-4"      
    ]    
    rand_bg = Enum.random(0..3)
    selected_bg = Enum.at(bg, rand_bg)
    "soup-os-bg-base #{selected_bg}"
  end

  @impl true
  def handle_info({:user_id, user_id}, socket),
    do: {:noreply, assign(socket, user_id: user_id)}

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  @impl true
  def handle_event("id-card-app", _assigns, socket) do
    IO.puts(":id-card-app")
    {:noreply, assign(socket, drawer_id: :id_card_app, page_title: "fn_id: :id-card-app")}
  end

  @impl true
  def handle_event("entangle-app", _assigns, socket) do
    IO.puts(":entangle-app")
    {:noreply, assign(socket, drawer_id: :entangle_app, page_title: "fn_id: :entangle-app")}
  end

  @impl true
  def handle_event("agi-app", _assigns, socket) do
    IO.puts(":agi-app")
    {:noreply, assign(socket, drawer_id: :agi_app, page_title: "fn_id: :agi-app")}
  end

  @impl true
  def handle_event("simulation-app", _assigns, socket) do
    IO.puts(":simulation-app")
    {:noreply, assign(socket, drawer_id: :simulation_app, page_title: "fn_id: :simulation-app")}
  end

  @impl true
  def handle_event("jobs-app", _assigns, socket) do
    IO.puts(":jobs-app")
    {:noreply, assign(socket, drawer_id: :jobs_app, page_title: "fn_id: :jobs-app")}
  end

  @impl true
  def handle_event("profession-app", _assigns, socket) do
    IO.puts(":profession-app")
    {:noreply, assign(socket, drawer_id: :profession_app, page_title: "fn_id: :profession-app")}
  end

  @impl true
  def handle_event("system-state-app", _assigns, socket) do
    IO.puts(":system-state-app")
    {:noreply, assign(socket, drawer_id: :system_state_app, page_title: "fn_id: :system-state-app")}
  end

  @impl true
  def handle_event("democratic-app", _assigns, socket) do
    IO.puts(":democratic-app")
    {:noreply, assign(socket, drawer_id: :democratic_app, page_title: "fn_id: :democratic-app")}
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
