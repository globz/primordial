defmodule PrimordialWeb.LiveHelpers do
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

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
          <%= live_patch "✖",
            to: @return_to,
            id: "close",
            class: "phx-modal-close",
            phx_click: hide_modal()
          %>
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
    <div id="modal" class="phx-modal fade-in id-card-fn">
     <div id="modal-content" class="phx-modal-content fade-in-scale">
      <a id="close" href="#" class="phx-modal-close" phx-click="close" phx-target="#id-card">✖</a>
      <%= render_slot(@inner_block) %>
     </div>
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
    class="copy-button" 
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
