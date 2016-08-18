defmodule Phamello.PageControllerTest do
  use Phamello.ConnCase
  import Phamello.Factory

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200)
  end

  test "GET / being logged in" do
    user = factory(:user)
    conn = guardian_login(user)
    |> get("/")

    assert redirected_to(conn) =~ "/app"
  end
end
