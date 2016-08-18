defmodule Phamello.GithubUser do
  alias Phamello.{Repo, User}

  defstruct [:username, :github_id]

  def find_or_create(%__MODULE__{} = github_user) do
    case Repo.get_by(User, github_user.github_id) do
      %User{} = user -> {:logged_in, user}
      nil -> validate_new_user(github_user)
    end
  end

  defp validate_new_user(%__MODULE__{} = github_user) do
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
