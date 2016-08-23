defmodule Phamello.TrelloTasks do
  alias Phamello.{Picture, TrelloClient}

  def push_to_board(pid, %Picture{} = picture) do
    {:ok, binary} = File.read(picture.local_url)

    case TrelloClient.create_card(picture, binary) do
      {:ok, %{"url" => url}} -> confirm_trello_push(pid, picture.id, url)
      {:error, error} -> bail_trello_push(pid, picture.id, error)
    end
  end

  defp confirm_trello_push(pid, picture_id, url) do
    GenServer.cast(pid, {:trello_notify_complete, picture_id, url})
  end

  defp bail_trello_push(pid, picture_id, error) do
    GenServer.cast(pid, {:trello_notify_error, picture_id, error})
  end
end
