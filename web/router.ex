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

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/auth", Phamello do
    pipe_through [:browser, :browser_auth]

    get "/github", AuthController, :request
    get "/github/callback", AuthController, :callback
    delete "/logout", SessionController, :logout
  end

  scope "/app", Phamello do
    pipe_through [:browser, :browser_auth]

    get "/", ApplicationController, :index
  end

  scope "/", Phamello do
    pipe_through [:browser, :browser_auth]

    get "/", PageController, :welcome
  end
end
