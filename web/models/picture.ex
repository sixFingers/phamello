defmodule Phamello.Picture do
  use Phamello.Web, :model

  schema "pictures" do
    field :name, :string
    field :description, :string
    field :local_url, :string
    field :remote_url, :string
    field :image, :any, virtual: true

    belongs_to :user, Phamello.User

    timestamps()
  end

  def create_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :image])
    |> validate_required([:name, :description, :image])
  end

  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:remote_url])
    |> validate_required([:remote_url])
  end
end
