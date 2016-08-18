defmodule Phamello.AuthControllerTest do
  use Phamello.ConnCase
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  import Phamello.Factory
  alias Phamello.{GithubClient, Repo, User}

  setup do
    {:ok, %{
      user: factory(:user),
      unsaved_user: factory(:unsaved_user)
    }}
  end

  test "GET /auth/github" do
    use_cassette "github_client_exchange_code" do
      response = GithubClient.exchange_code("3d78e36b393e44ecbbd5")
      assert %{"access_token" => _token} = response
    end
  end

  test "GET /auth/github with bad code" do
    use_cassette "github_client_exchange_code_bad_code" do
      response = GithubClient.exchange_code("9857a21fe48c2204558d")
      assert %{"error" => _error} = response
    end
  end

  test "GET /auth/github/callback" do
    use_cassette "github_client_get_user" do
      response = GithubClient.get_user("5f3a41f0c5b195b58b6f99cd9397826b1b0cd5c3")
      assert %{"login" => _login} = response
    end
  end

  test "GET /auth/github/callback with wrong token" do
    use_cassette "github_client_get_user_bad_token" do
      response = GithubClient.get_user("5f3a41asdf195b58b6f99cd9397826b1b0cd5c3")
      refute match? %{"login" => _login}, response
    end
  end

  test "GET /auth/github being logged in", %{user: user} do
    conn = guardian_login(user)
    |> get("/auth/github")

    assert redirected_to(conn) =~ "/app"
  end

  test "GET /app without being logged in", %{conn: conn} do
    conn = get(conn, "/app")
    assert html_response(conn, 401)
  end

  test "GET /logout without being logged in", %{conn: conn} do
    conn = delete(conn, "/auth/logout")

    assert redirected_to(conn, 302) =~ "/"
  end

  test "GET /app gets logged in from database", %{unsaved_user: user} do
    {:ok, changeset} = Repo.insert(user)

    resource = guardian_login(%User{id: changeset.id})
    |> bypass_through(Phamello.Router, [:browser, :browser_auth])
    |> get("/app")
    |> Guardian.Plug.current_resource

    assert %User{} = resource
    assert resource.github_id == user.github_id
  end
end
