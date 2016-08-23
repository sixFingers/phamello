defmodule Phamello.GithubUser do
  alias Phamello.{Repo, User}

  def find_or_create(%{github_id: gid} = github_user) do
    case Repo.get_by(User, github_id: gid) do
      %User{} = user -> {:logged_in, user}
      nil -> validate_new_user(github_user)
    end
  end

  defp validate_new_user(github_user) do
    changeset = User.creation_changeset(%User{}, github_user)

    case changeset.valid? do
      true -> create_user(changeset)
      false -> {:error, nil}
    end
  end

  defp create_user(%Ecto.Changeset{} = changeset) do
    case Repo.insert(changeset) do
      {:ok, %User{} = user} -> {:registered, user}
      {:error, _} -> {:error, nil}
    end
  end
end
