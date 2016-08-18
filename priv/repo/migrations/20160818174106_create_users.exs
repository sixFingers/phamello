defmodule Phamello.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :username, :string
      add :github_id, :integer
      timestamps()
    end

    create index(:users, [:github_id], unique: true)
  end
end
