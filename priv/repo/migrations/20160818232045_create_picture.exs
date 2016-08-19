defmodule Phamello.Repo.Migrations.CreatePicture do
  use Ecto.Migration

  def change do
    create table(:pictures) do
      add :name, :string
      add :description, :string
      add :local_url, :string

      timestamps()
    end

  end
end
