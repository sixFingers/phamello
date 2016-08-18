defmodule Phamello.User do
  use Phamello.Web, :model
  alias Phamello.Repo

  schema "users" do
    field :username, :string
    field :github_id, :integer
    timestamps()
  end

  def creation_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:username, :github_id])
    |> validate_required([:username, :github_id])
  end
end
