defmodule Phamello.PageController do
  use Phamello.Web, :controller

  def welcome(conn, _params) do
    render(conn, "index.html")
  end
end
