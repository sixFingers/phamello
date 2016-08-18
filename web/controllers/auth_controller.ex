defmodule Phamello.AuthController do
  use Phamello.Web, :controller
  alias Phamello.{GithubClient, User}

  def request(conn, _params) do
    redirect(conn, external: GithubClient.authorize_url)
  end

  def callback(conn, %{"code" => code}) do
    case GithubClient.authenticate(code) do
      {:ok, user} -> authentication_success(conn, user)
      {:error, _} -> authentication_error(conn)
    end
  end

  defp authentication_success(conn, %{} = user) do
    case Repo.get_by(User, github_id: user.github_id) do
      %User{} -> logged_in(conn)
      nil -> validate_new_user(conn, user)
    end
  end

  defp authentication_error(conn) do
    conn
    |> put_status(401)
    |> put_flash(:errpr, "Couldn't authenticate.")
    |> redirect(to: "/")
  end

  defp logged_in(conn) do
    conn
    |> put_flash(:info, "Authenticated succesfully")
    |> redirect(to: "/")
  end

  defp validate_new_user(conn, user) do
    changeset = User.creation_changeset(%User{}, user)

    case changeset.valid? do
      true -> create_user(conn, changeset)
      false -> authentication_error(conn)
    end
  end

  defp create_user(conn, %Ecto.Changeset{} = changeset) do
    case Repo.insert(changeset) do
      {:ok, %User{}} -> registration_success(conn)
      {:error, _} -> authentication_error(conn)
    end
  end

  defp registration_success(conn) do
    conn
    |> put_flash(:info, "User succesfully registered")
    |> redirect(to: "/")
  end
end
