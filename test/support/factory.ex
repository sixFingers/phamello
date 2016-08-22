defmodule Phamello.Factory do
  alias Phamello.User

  def factory(resource), do: factory(resource, [])

  def factory(:user, []) do
    %User{
      id: 1,
      username: "tomfulp",
      github_id: 123456
    }
  end

  def factory(:unsaved_user, []) do
    %User{
      username: "ginger",
      github_id: 987654
    }
  end

  def factory(:picture_map, opts) do
    %{
      name: "McGyver",
      description: "Great show",
      image: factory(:image, opts)
    }
  end

  def factory(:image, []) do
    %Plug.Upload{
      path: "fixture/images/face.jpg",
      filename: "face.jpg"
    }
  end

  def factory(:image, [size: :big]) do
    %Plug.Upload{
      path: "fixture/images/big.jpg",
      filename: "big.jpg"
    }
  end
end
