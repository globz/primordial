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
    <div class="flex justify-center h-screen">
      <div class="w-full sm:w-2/3 md:w-1/2 lg:w-1/3 xl:w-1/4 mx-2">
        <div class="relative w-full h-48">
          <div class="id-card">
            <div class="scc-tripe"></div>
          </div>
          <div class="w-full sm:w-4/5 lg:w-96 swiper-top"></div>
          <div class="w-full sm:w-4/5 lg:w-96 swiper-bottom">
            <div class={@reader_state}></div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
