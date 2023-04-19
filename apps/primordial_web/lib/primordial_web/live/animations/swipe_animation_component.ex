defmodule PrimordialWeb.Animations.SwipeAnimationComponent do
  use PrimordialWeb, :live_component

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    case assigns.reader_state do
      :valid ->
        Process.send_after(self(), :swipe_accepted, 2000)
      :invalid ->
        Process.send_after(self(), :swipe_denied, 2000)
    end
    {:ok,
     socket
     |> assign(assigns)
     |> assign(reader_state: "light-indicator-#{assigns.reader_state}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
      <div class="swipe-animation">      
        <div class="credit-card">
          <div class="scc-tripe"></div>
        </div>
        <div class="swiper-top"></div>
        <div class="swiper-bottom">
        <div class={@reader_state}></div>
        </div>
      </div>
    """
  end
end
