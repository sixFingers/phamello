defmodule Phamello.UserChannel do
  use Phoenix.Channel
  use Guardian.Channel

  def join("user:" <> user_id, %{claims: _claims, resource: resource}, socket) do
    if (user_id == "#{resource.id}") do
      {:ok, %{message: :signed_in}, socket}
    else
      {:error, %{error: :unauthorized}}
    end
  end

  def join("user:" <> _user_id, _token, _socket) do
    {:error, %{error: :unauthenticated}}
  end
end
