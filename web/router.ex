defmodule Phamello.Router do
  use Phamello.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser_auth do
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource
  end

  pipeline :authenticated_only do
    plug Guardian.Plug.EnsureAuthenticated,
      handler: Phamello.AuthController
  end

  pipeline :not_authenticated_only do
    plug Guardian.Plug.EnsureNotAuthenticated,
      handler: Phamello.AuthController
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", Phamello do
    pipe_through [:browser, :browser_auth, :authenticated_only]

    get "/logout", AuthController, :logout
  end

  scope "/auth", Phamello do
    pipe_through [:browser, :browser_auth, :not_authenticated_only]

    get "/github", AuthController, :request
    get "/github/callback", AuthController, :callback
  end

  scope "/app", Phamello do
    pipe_through [:browser, :browser_auth, :authenticated_only]

    get "/", PageController, :application
  end

  scope "/", Phamello do
    pipe_through [:browser]

    get "/", PageController, :welcome
  end
end
