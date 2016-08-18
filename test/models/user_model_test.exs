defmodule Phamello.UserModelTest do
  use Phamello.ModelCase

  alias Phamello.User

  @valid_attrs %{username: "sixFingers", github_id: 123456}
  @invalid_attrs %{}

  test "creation changeset with valid attributes" do
    changeset = User.creation_changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "creation changeset with invalid attributes" do
    changeset = User.creation_changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end
end
