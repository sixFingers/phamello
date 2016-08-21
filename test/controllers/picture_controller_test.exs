defmodule Phamello.PictureControllerTest do
  use Phamello.ConnCase
  import Phamello.Factory
  alias Phamello.{Picture, Repo, User}

  @invalid_attrs %{}

  setup do
    user = factory(:user)

    {:ok, %{
      picture_map: factory(:picture_map),
      conn: guardian_login(user)
        |> guardian_impersonate(user),
      user: user
    }}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, picture_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing pictures"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = get conn, picture_path(conn, :new)
    assert html_response(conn, 200) =~ "New picture"
  end

  test "creates resource and redirects when data is valid", %{conn: conn, picture_map: picture_map} do
    conn = post conn, picture_path(conn, :create), picture: picture_map
    assert redirected_to(conn) == picture_path(conn, :index)

    picture = Repo.get_by(Picture, Map.take(picture_map, [:name, :description]))
    assert picture
    assert File.exists?(picture.local_url)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, picture_path(conn, :create), picture: @invalid_attrs
    assert html_response(conn, 200) =~ "New picture"
  end

  test "shows chosen resource", %{conn: conn} do
    picture = Repo.insert! %Picture{}
    conn = get conn, picture_path(conn, :show, picture)
    assert html_response(conn, 200) =~ "Show picture"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, picture_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    picture = Repo.insert! %Picture{}
    conn = get conn, picture_path(conn, :edit, picture)
    assert html_response(conn, 200) =~ "Edit picture"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn, picture_map: picture_map} do
    picture = Repo.insert! struct(Picture, picture_map)
    conn = put conn, picture_path(conn, :update, picture), picture: picture_map
    assert redirected_to(conn) == picture_path(conn, :show, picture)
    assert Repo.get_by(Picture, Map.take(picture, [:name, :description]))
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    picture = Repo.insert! %Picture{}
    conn = put conn, picture_path(conn, :update, picture), picture: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit picture"
  end

  test "deletes chosen resource", %{conn: conn} do
    picture = Repo.insert! %Picture{}
    conn = delete conn, picture_path(conn, :delete, picture)
    assert redirected_to(conn) == picture_path(conn, :index)
    refute Repo.get(Picture, picture.id)
  end
end
