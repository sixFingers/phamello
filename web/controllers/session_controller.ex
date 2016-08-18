defmodule Phamello.SessionController do
  use Phamello.Web, :controller

  plug Guardian.Plug.EnsureAuthenticated,
      handler: __MODULE__

  def logout(conn, _params) do
    conn
    |> Guardian.Plug.sign_out
    |> put_flash(:info, "Logged out")
    |> redirect(to: "/")
  end

  def unauthenticated(conn, _params) do
    conn
    |> redirect(to: "/")
  end
end
