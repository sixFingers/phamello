defmodule Phamello.GuardianSerializer do
  @behaviour Guardian.Serializer

  alias Phamello.Repo
  alias Phamello.User

  def for_token(user = %User{}), do: {:ok, "id:#{user.id}"}
  def for_token(_), do: { :error, "Unknown resource type" }

  def from_token("id:" <> id), do: {:ok, Repo.get(User, id)}
  def from_token(_), do: {:error, "User not found"}
end
