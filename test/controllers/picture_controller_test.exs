defmodule Phamello.PictureControllerTest do
  use Phamello.ConnCase
  import Phamello.Factory
  alias Phamello.{Picture, Repo, User, StorageHelper, PictureWorker}
  import Mock

  @invalid_attrs %{}

  setup do
    user = factory(:unsaved_user) |> Repo.insert!

    on_exit fn -> StorageHelper.clear_fixtures_storage() end

    {:ok, %{
      picture_map: factory(:picture_map),
      big_picture_map: factory(:picture_map, size: :big),
      conn: guardian_login(user),
      user: user
    }}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, picture_path(conn, :index)
    assert html_response(conn, 200)
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, picture_path(conn, :new)
    assert html_response(conn, 200)
  end

  test_with_mock "creates resource and redirects when data is valid",
    %{conn: conn, picture_map: picture_map},
    PictureWorker, [], [handle_picture: fn(_) -> :ok end] do

    conn = post conn, picture_path(conn, :create), picture: picture_map
    assert redirected_to(conn) == picture_path(conn, :index)

    picture = Repo.get_by(Picture, Map.take(picture_map, [:name, :description]))
    assert picture
    assert File.exists?(Picture.get_local_path(picture))
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, picture_path(conn, :create), picture: @invalid_attrs
    assert html_response(conn, 200)
  end

  test "does not create resource and renders errors when image size is too big", %{conn: conn, big_picture_map: picture_map} do
    conn = post conn, picture_path(conn, :create), picture: picture_map
    assert html_response(conn, 200)
  end

  test "deletes chosen resource", %{conn: conn, user: user, picture_map: picture_map} do
    picture = build_assoc(user, :pictures)
    |> Picture.create_changeset(picture_map)
    |> Repo.insert!

    conn = delete conn, picture_path(conn, :delete, picture)
    assert redirected_to(conn) == picture_path(conn, :index)
    refute Repo.get(Picture, picture.id)
    refute File.exists?(Picture.get_local_path(picture))
  end

  test "renders 404 when deleting resource not belonging to user", %{conn: conn, picture_map: picture_map} do
    user = factory(:user) |> Repo.insert!

    picture = build_assoc(user, :pictures)
    |> Picture.create_changeset(picture_map)
    |> Repo.insert!

    assert_error_sent 404, fn ->
      delete conn, picture_path(conn, :delete, picture)
    end
  end
end
