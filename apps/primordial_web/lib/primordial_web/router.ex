defmodule PrimordialWeb.Router do
  use PrimordialWeb, :router

  import PrimordialWeb.AdminAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PrimordialWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_admin
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PrimordialWeb do
    pipe_through :browser

    get "/session/:token", SessionController, :create
    get "/session/soup/:state", SessionController, :update_soup_state

    live "/", PageLive, :index
    live "/swipe", SwipeLive, :authenticate
    live "/import", ImportLive, :import
    live "/soup", SoupLive, :sign_in

    # live_session :authenticated, on_mount: {PrimordialWeb.InitAssigns, :authenticated} do
    #   live "/swipe", SwipeLive, :authenticate
    #   live "/soup", SoupLive, :sign_in
    # end
  end

  scope "/enroll", PrimordialWeb.Enroll, as: :enroll do
    pipe_through :browser

    live "/users", UserLive.Index, :index
    live "/users/new", UserLive.Index, :new
    live "/users/:id/edit", UserLive.Index, :edit

    live "/users/:id", UserLive.Show, :show
    live "/users/:id/show/edit", UserLive.Show, :edit
  end

  # Other scopes may use custom stacks.
  # scope "/api", PrimordialWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test, :prod] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through [:browser, :require_authenticated_admin]

      live_dashboard "/panopticon/dashboard", metrics: PrimordialWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", PrimordialWeb do
    pipe_through [:browser, :redirect_if_admin_is_authenticated]

    live_session :redirect_if_admin_is_authenticated,
      on_mount: [{PrimordialWeb.AdminAuth, :redirect_if_admin_is_authenticated}] do
      live "/panopticon/log_in", AdminLoginLive, :new
      live "/panopticon/reset_password", AdminForgotPasswordLive, :new
      live "/panopticon/reset_password/:token", AdminResetPasswordLive, :edit
    end

    post "/panopticon/log_in", AdminSessionController, :create
  end

  ## Authenticated routes

  scope "/", PrimordialWeb do
    pipe_through [:browser, :require_authenticated_admin]

    get "/panopticon/log_out", AdminSessionController, :delete

    live_session :require_authenticated_admin,
      on_mount: [{PrimordialWeb.AdminAuth, :ensure_authenticated}] do
      live "/panopticon/settings", AdminSettingsLive, :edit
      live "/panopticon/settings/confirm_email/:token", AdminSettingsLive, :confirm_email
      live "/panopticon/tower", AdminTowerLive, :watch
      live "/panopticon/register", AdminRegistrationLive, :new
    end
  end

  scope "/", PrimordialWeb do
    pipe_through [:browser]

    delete "/panopticon/log_out", AdminSessionController, :delete

    live_session :current_admin,
      on_mount: [{PrimordialWeb.AdminAuth, :mount_current_admin}] do
      live "/panopticon/confirm/:token", AdminConfirmationLive, :edit
      live "/panopticon/confirm", AdminConfirmationInstructionsLive, :new
    end
  end
end
