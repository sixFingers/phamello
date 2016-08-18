defmodule Phamello.AuthControllerTest do
  use Phamello.ConnCase
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias Phamello.GithubClient

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
end
