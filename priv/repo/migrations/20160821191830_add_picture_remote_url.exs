defmodule Phamello.Repo.Migrations.AddPictureRemoteUrl do
  use Ecto.Migration

  def change do
    alter table(:pictures) do
      add :remote_url, :string
    end
  end
end
