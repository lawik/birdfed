defmodule BirdfedWeb.Router do
  use BirdfedWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {BirdfedWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  alias Birdfed.Fed

  pipeline :fedi do
    plug :accepts, ["json"]
    plug Fedex.Webfinger.Plug, fetcher: &Fed.fetch_fingers/1
    plug Fedex.Activitystreams.Plug, fetcher: &Fed.fetch_fingers/1
  end

  pipeline :fedi_signed do
    plug Fedex.Activitypub.HttpSigned
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/inbox", BirdfedWeb do
    pipe_through :fedi_signed

    get "/", PageController, :home
    post "/", PageController, :home
  end

  scope "/", BirdfedWeb do
    pipe_through :fedi
    # get "/", PageController, :missing
    # post "/", PageController, :missing
    # put "/", PageController, :missing
    # delete "/", PageController, :missing
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:birdfed, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BirdfedWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
