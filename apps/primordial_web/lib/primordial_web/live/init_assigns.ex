defmodule PrimordialWeb.InitAssigns do
  @moduledoc """
  Ensures common `assigns` are applied to all LiveViews attaching this hook.
  https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#on_mount/1
  https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.Router.html#live_session/3
  """
  import Phoenix.LiveView

  def on_mount(:authenticated, _params, _session, socket) do
    {:cont, assign(socket, :page_title, "DemoWeb")}
  end

end
