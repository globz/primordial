defmodule PrimordialWeb.SoupLive do
  use PrimordialWeb, :live_view 
  
  alias Primordial.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-row grow basis-1/5 lg:basis-1/2 p-2 ml-1 pt-16
    self-center justify-center">
     <div id="os-icon" class="flex soup-os-icon bg-id-card-icon mr-[5px]"></div>
     <div id="os-icon" class="flex soup-os-icon bg-entangle-icon mr-[5px]"></div>
     <div id="os-icon" class="flex soup-os-icon bg-agi-icon bg-black mr-[5px]"></div>
     <div id="os-icon" class="flex soup-os-icon bg-simulation-icon mr-[5px]"></div>
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
        bg: select_bg())
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
end
