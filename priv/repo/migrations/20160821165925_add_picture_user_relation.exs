defmodule Phamello.Repo.Migrations.AddPictureUserRelation do
  use Ecto.Migration

  def change do
    alter table(:pictures) do
      add :user_id, references(:users)
    end

    create index(:pictures, [:user_id])
  end
end
