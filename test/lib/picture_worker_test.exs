defmodule Phamello.PictureWorkerTest do
  use Phamello.ConnCase
  import Phamello.Factory
  alias Phamello.{Repo, User, Picture, StorageHelper}

  @fake_remote_url "this_is_a_remote_url"

  setup do
    user = factory(:unsaved_user) |> Repo.insert!

    on_exit fn -> StorageHelper.clear_fixtures_storage() end

    {:ok, %{
      user: user,
      picture_map: factory(:picture_map),
    }}
  end

  test "creation changeset with invalid attributes", %{user: user, picture_map: picture_map} do
    picture = build_assoc(user, :pictures)
    |> Picture.create_changeset(picture_map)
    |> Repo.insert!

    {:ok, state} = Phamello.PictureWorker.init([])

    Phamello.PictureWorker.handle_cast({:s3_upload_complete, picture.id, @fake_remote_url}, state)

    picture = Repo.get!(Picture, picture.id)
    assert picture.remote_url == @fake_remote_url
  end
end
