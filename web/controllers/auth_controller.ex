defmodule Phamello.AuthController do
  use Phamello.Web, :controller
  alias Phamello.{GithubClient, GithubUser, User}

  plug Guardian.Plug.EnsureNotAuthenticated,
      handler: __MODULE__

  def request(conn, _params) do
    redirect(conn, external: GithubClient.authorize_url)
  end

  def callback(conn, %{"code" => code}) do
    case GithubClient.authenticate(code) do
      {:ok, user} -> authentication_complete(conn, user)
      {:error, _} -> authentication_error(conn)
    end
  end

  def already_authenticated(conn, _params) do
    redirect(conn, to: "/app")
  end

  defp authentication_complete(conn, %GithubUser{} = user) do
    case GithubUser.find_or_create(user) do
      {:logged_in, user} -> authentication_success(conn, user)
      {:registered, user} -> registration_success(conn, user)
      {:error, _} -> authentication_error(conn)
    end
  end

  defp authentication_error(conn) do
    conn
    |> put_status(401)
    |> put_flash(:errpr, "Couldn't authenticate.")
    |> redirect(to: "/")
  end

  defp authentication_success(conn, user) do
    conn
    |> Guardian.Plug.sign_in(user)
    |> put_flash(:info, "Authenticated succesfully")
    |> redirect(to: "/app")
  end

  defp registration_success(conn, %User{} = user) do
    conn
    |> Guardian.Plug.sign_in(user)
    |> put_flash(:info, "User succesfully registered")
    |> redirect(to: "/app")
  end
end
