defmodule Phamello.Picture do
  use Phamello.Web, :model

  schema "pictures" do
    field :name, :string
    field :description, :string
    field :local_url, :string
    field :image, :any, virtual: true

    belongs_to :user, Phamello.User

    timestamps()
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :image])
    |> validate_required([:name, :description, :image])
  end
end
