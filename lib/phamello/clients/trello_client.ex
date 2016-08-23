defmodule Phamello.TrelloClient do
  alias Phamello.Picture

  @api_url "https://api.trello.com"
  @boards_path "/1/members/me"
  @cards_path "/1/cards"
  @card_attachments_path "/attachments"

  def create_card(%Picture{} = picture) do
    case create_base_card(%Picture{} = picture) do
      {:ok, card} -> do_create_attachment(card, picture)
      {:error, error} -> {:error, error}
    end
  end

  def create_base_card(%Picture{} = picture) do
    case get_list_id(config[:board_name], config[:list_name]) do
      {:ok, list_id} -> do_create_base_card(list_id, picture)
      {:error, error} -> {:error, error}
    end
  end

  def get_list_id(board, list) do
    case fetch_boards do
      {:ok, boards} -> {:ok, do_get_list_id(boards, board, list)}
      {:error, error} -> {:error, error}
    end
  end

  defp do_create_attachment(%{"id" => id} = card, picture) do
    response = "#{@cards_path}/#{id}#{@card_attachments_path}"
    |> full_url(auth_params)
    |> HTTPoison.post!(attachment_body(picture))
    |> parse_response

    case response do
      {:ok, _} -> {:ok, card}
      {:error, error} -> {:error, error}
    end
  end

  def do_create_base_card(list_id, picture) do
    @cards_path
    |> full_url(card_params(list_id, picture))
    |> HTTPoison.post!("")
    |> parse_response
  end

  def do_get_list_id(boards, board, list) do
    boards
    |> map_boards
    |> select_board(board)
    |> select_board_list(list)
  end

  defp select_board(boards, board) do
    case Map.get(boards, board, nil) do
      nil -> raise "Board not found"
      board -> board
    end
  end

  defp select_board_list(board, list) do
    case Map.get(board, list, nil) do
      nil -> raise "List not found"
      list -> list
    end
  end

  defp fetch_boards do
    @boards_path
    |> full_url(boards_params)
    |> HTTPoison.get!
    |> parse_response
  end

  defp map_boards(%{"boards" => boards}) do
    boards
    |> Enum.reduce(%{}, fn(%{"name" => name, "lists" => lists}, acc) ->
      Map.put(acc, name, map_lists(lists))
    end)
  end

  defp map_lists(lists) do
    lists
    |> Enum.reduce(%{}, fn(%{"id" => id, "name" => name}, acc) ->
      Map.put(acc, name, id)
    end)
  end

  defp parse_response(%HTTPoison.Response{status_code: 200, body: body}), do:
    {:ok, Poison.decode!(body)}

  defp parse_response(%HTTPoison.Response{status_code: _, body: body}), do:
    {:error, body}

  defp full_url(path, params) do
    query = URI.encode_query(params)

    @api_url
    |> URI.merge(path)
    |> URI.merge("?#{query}")
    |> URI.to_string
  end

  defp config, do: Application.get_env(:phamello, __MODULE__)

  defp auth_params do
    [key: config[:api_key], token: config[:api_token]]
    |> Enum.into(%{})
  end

  defp boards_params do
    auth_params
    |> Map.merge(%{
      "boards" => "all",
      "board_lists" => "all"
    })
  end

  defp card_params(list_id, picture) do
    auth_params
    |> Map.merge(%{
      "idList" => list_id,
      "name" => picture.name,
      "due" => picture.updated_at,
      "desc" => "#{picture.description}\n\n_#{picture.user.username}_"
    })
  end

  defp attachment_body(picture) do
    {:multipart, [
      {"name", picture.name},
      {:file, Picture.get_local_path(picture)}
    ]}
  end
end
