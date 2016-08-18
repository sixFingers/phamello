defmodule Phamello.AuthController do
  use Phamello.Web, :controller
  alias Phamello.GithubClient

  def request(conn, _params) do
    redirect(conn, external: GithubClient.authorize_url)
  end

  def callback(conn, %{"code" => code}) do
    user = GithubClient.authenticate(code)
    handle_callback(conn, user)
  end

  defp handle_callback(conn, {:ok, user}) do
    conn
    |> put_flash(:info, user)
    |> redirect(to: "/")
  end

  defp handle_callback(conn, {:error, _error}) do
    conn
    |> put_flash(:info, "Couldn't authenticate with Github")
    |> redirect(to: "/")
  end
end
