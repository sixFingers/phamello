defmodule Phamello.GithubClient do
  use HTTPoison.Base

  @site_url "https://api.github.com"
  @authorize_url "https://github.com/login/oauth/authorize"
  @token_url "https://github.com/login/oauth/access_token"
  @default_headers [{"Accept", "application/json"}]

  def authenticate(code) do
    exchange_code(code)
    |> handle_oauth_step
  end

  def exchange_code(code) do
    do_request(:post, exchange_code_url(code))
    |> parse_response
  end

  def get_user(token) do
    do_request(:get, user_info_url(token))
    |> parse_response
  end

  def authorize_url, do:
    <<@authorize_url :: binary, "?", authorize_params :: binary>>

  defp config, do: Application.get_env(:phamello, __MODULE__)

  defp do_request(method, url), do:
    request(method, url, "", @default_headers)

  defp parse_response({:ok, %{body: body}}), do: Poison.decode!(body)
  defp parse_response({:error, _response}), do: {:error, nil}

  defp handle_oauth_step(%{"access_token" => token}) do
    get_user(token)
    |> handle_oauth_step
  end

  defp handle_oauth_step(%{"login" => username, "id" => id}), do:
    {:ok, %{username: username, github_id: id}}

  defp handle_oauth_step(_), do: {:error, nil}

  defp exchange_code_url(code), do:
    <<@token_url :: binary, "?", exchange_code_params(code) :: binary>>

  defp user_info_url(token), do:
    <<@site_url :: binary, "/user?", user_info_params(token) :: binary>>

  defp authorize_params do
    [client_id: config[:client_id]]
    |> URI.encode_query
  end

  defp exchange_code_params(code) do
    [code: code]
    |> Keyword.merge(config)
    |> URI.encode_query
  end

  defp user_info_params(token) do
    [access_token: token]
    |> URI.encode_query
  end
end
