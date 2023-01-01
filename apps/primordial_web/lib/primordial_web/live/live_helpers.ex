defmodule PrimordialWeb.LiveHelpers do
  #import Phoenix.LiveView
  import Phoenix.Component

  alias Phoenix.LiveView.JS

  @doc """
  Renders a live component inside a modal.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <.modal return_to={Routes.user_index_path(@socket, :index)}>
        <.live_component
          module={PrimordialWeb.Enroll.UserLive.FormComponent}
          id={@user.id || :new}
          title={@page_title}
          action={@live_action}
          return_to={Routes.user_index_path(@socket, :index)}
          user: @user
        />
      </.modal>
  """
  def modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

          # <%= live_patch "✖",
          #   to: @return_to,
          #   id: "close",
          #   class: "phx-modal-close",
          #   phx_click: hide_modal()
          # %>

    ~H"""
    <div id="modal" class="phx-modal fade-in" phx-remove={hide_modal()}>
      <div
        id="modal-content"
        class="phx-modal-content fade-in-scale"
        phx-click-away={JS.dispatch("click", to: "#close")}
        phx-window-keydown={JS.dispatch("click", to: "#close")}
        phx-key="escape"
      >
        <%= if @return_to do %>

        <% else %>
          <a id="close" href="#" class="phx-modal-close" phx-click={hide_modal()}>✖</a>
        <% end %>

        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  defp hide_modal(js \\ %JS{}) do
    js
    |> JS.hide(to: "#modal", transition: "fade-out")
    |> JS.hide(to: "#modal-content", transition: "fade-out-scale")
  end

  @doc """
  Renders a live component inside an id_card_fn_modal.

  The rendered modal has no `:return_to` option and is to be strictly used with
  IdCardComponent and IdCardFunctions


  ## Examples

      <.id_card_fn_modal>
        <.live_component
          module={IdCardFunctions.Export}
          id={@user.id}
          title={@page_title}
          user: @user
        />
      </.id_card_fn_modal>
  """
  def id_card_fn_modal(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)

    ~H"""
    <div id="modal" class="phx-modal fade-in">
     <div id="modal-content" class="phx-modal-content fade-in-scale flex flex-row flex-wrap w-full lg:w-[80%] rounded-xl">
      <a id="close" href="#" class="basis-full phx-modal-close text-right" phx-click="close" phx-window-keyup="close_with_key" phx-target="#id-card">✖</a>
      <%= render_slot(@inner_block) %>
     </div>
    </div>
    """
  end

  @doc """
  Renders a live component inside soup_app_drawer.

  The rendered drawer has no `:return_to` option and is to be strictly used with
  SoupLive & AppDrawer


  ## Examples

      <.soup_app_drawer>
        <.live_component
          module={PrimordialWeb.SoupComponents.AppDrawer}
          id={@user.id}
          drawer_id={@drawer_id}
          user: @user
        />
      </.soup_app_drawer>
  """
  def soup_app_drawer(assigns) do
    assigns = assign_new(assigns, :return_to, fn -> nil end)
    
    ~H"""
    <div id="drawer" class="fixed z-40 p-4 overflow-y-clip border-2
    border-indigo-600 p-5 h-[85vh] md:h-[95vh] lg:h-full w-[85%] md:w-[70%] lg:w-[30%] bg-white
    dark:bg-gray-800 rounded-4xl inset-y-0" tabindex="-1">
       <h5 id="drawer-label" class="inline-flex items-center mb-4 text-base font-semibold text-gray-500 dark:text-gray-400"><svg class="w-5 h-5 mr-2" aria-hidden="true" fill="currentColor" viewBox="0 0 20 20" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path></svg>Info</h5>
       <a id="close" href="#" class="phx-modal-close text-right" phx-click="close" phx-window-keyup="close_with_key" phx-target="#app-drawer">✖</a>
       <%= render_slot(@inner_block) %>
    </div>
    """    
  end  

  @doc """
  Renders a clipboard button.

  The rendered button receives a `:copy_from` option to properly target the selected
  textContent of a given element id.

  `:copy_from` refers to an element id


  ## Examples

      <.clipboard_button copy_from={@element_id} />
  """
  def clipboard_button(assigns) do
    assigns = assign_new(assigns, :copy_from, fn -> "#" end)

    ~H"""
    <button 
    phx-click={JS.dispatch("primordial_web:clipcopy", to: @copy_from)}
    class="copy-button invisible group-hover:visible" 
    aria-label="copy">
    <svg xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 0 24 24"
    width="24px" fill="currentColor"><path d="M0 0h24v24H0z"
    fill="none"></path><path d="M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3
    4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9
    2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z">
    </path>
    </svg>
    </button>
    """
  end    
end
