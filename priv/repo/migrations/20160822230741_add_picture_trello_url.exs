defmodule Phamello.Repo.Migrations.AddPictureTrelloUrl do
  use Ecto.Migration

  def change do
    alter table(:pictures) do
      add :trello_url, :string
    end

    create index(:pictures, [:trello_url])
  end
end
