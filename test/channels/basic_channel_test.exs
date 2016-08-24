defmodule Phamello.BasicChannelTest do
  use Phamello.ChannelCase
  alias Phamello.UserChannel
  import Phamello.Factory

  setup do
    user = factory(:unsaved_user) |> Phamello.Repo.insert!

    {:ok, jwt, _} = Guardian.encode_and_sign(user)
    {:ok, _, socket} = socket()
      |> subscribe_and_join(UserChannel, "user:#{user.id}", %{"guardian_token" => "#{jwt}"})

    {:ok, %{jwt: jwt, socket: socket, user: user}}
  end

  test "Unauthenticated users cannot join", %{user: user} do
    response = socket() |> Phoenix.ChannelTest.join(UserChannel, "user:#{user.id}")
    assert {:error, %{error: :unauthenticated}} = response
  end

  test "Authenticated users cannot subscribe to other's channels", %{jwt: jwt} do
    response = socket() |> subscribe_and_join(UserChannel, "user:999", %{"guardian_token" => "#{jwt}"})
    assert {:error, %{error: :unauthorized}} = response
  end

  test "Authenticated users successfully subscribe to their own channel", %{user: user, jwt: jwt} do
    response = socket() |> subscribe_and_join(UserChannel, "user:#{user.id}", %{"guardian_token" => "#{jwt}"})
    assert {:ok, %{message: :signed_in}, _socket} = response
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "picture", %{id: 99}
    assert_push "picture", %{id: 99}
  end
end
