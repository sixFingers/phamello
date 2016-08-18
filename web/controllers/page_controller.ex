defmodule Phamello.PageController do
  use Phamello.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
