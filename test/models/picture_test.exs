defmodule Phamello.PictureTest do
  use Phamello.ModelCase
  import Phamello.Factory
  alias Phamello.Picture

  @invalid_attrs %{}

  setup do
    {:ok, %{
      picture_map: factory(:picture_map),
    }}
  end

  test "changeset with valid attributes", %{picture_map: picture_map} do
    changeset = Picture.insert_changeset(%Picture{}, picture_map)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Picture.insert_changeset(%Picture{}, @invalid_attrs)
    refute changeset.valid?
  end
end
