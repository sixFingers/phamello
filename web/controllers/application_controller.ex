defmodule Phamello.ApplicationController do
  use Phamello.Web, :controller

  plug Guardian.Plug.EnsureAuthenticated,
      handler: __MODULE__

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> put_flash(:error, "Authentication required")
    |> redirect(to: "/")
  end
end
