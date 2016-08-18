defmodule Phamello.ViewHelpers do
  def logged_in?(conn), do: Guardian.Plug.authenticated?(conn)
  def current_user(conn), do: Guardian.Plug.current_resource(conn)
end
