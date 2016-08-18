defmodule Phamello.PageController do
  use Phamello.Web, :controller

  plug Guardian.Plug.EnsureNotAuthenticated,
      handler: __MODULE__

  def welcome(conn, _params) do
    render(conn, "welcome.html")
  end

  def already_authenticated(conn, _params) do
    conn
    |> redirect(to: "/app")
  end
end
