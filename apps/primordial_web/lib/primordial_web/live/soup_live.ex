defmodule PrimordialWeb.SoupLive do
  use PrimordialWeb, :live_view 
  
  alias Primordial.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-row flex-wrap border-solid border-4
    border-indigo-600 rounded-4xl h-[80vh] lg:h-[95vh] max-w-full
    bg-[steelblue]">
    <div class="basis-full rounded-4xl bg-soup-os-bg-2 bg-no-repeat bg-center
    bg-cover bg-origin-border max-w-full max-h-full lg:h-[95vh]">
     <div class="basis-full p-1 ml-1">
     <div id="os-icon" class="flex os-icon bg-id-card-icon mr-[5px]"></div>
     </div>
    </div>
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
        soup_state: state)
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

  @impl true
  def handle_info({:user_id, user_id}, socket),
    do: {:noreply, assign(socket, user_id: user_id)}

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
