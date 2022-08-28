defmodule PrimordialWeb.Router do
  use PrimordialWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PrimordialWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
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
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: PrimordialWeb.Telemetry
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
end
