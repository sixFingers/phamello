defmodule Phamello.Factory do
  alias Phamello.User

  def factory(:user) do
    %User{
      id: 1,
      username: "tomfulp",
      github_id: 123456
    }
  end
end
