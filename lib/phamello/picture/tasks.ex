defmodule Phamello.PictureTasks do
  alias Phamello.{Picture, S3Client}

  def upload_to_s3(pid, client, bucket, %Picture{} = picture) do
    path = picture.user_id
    |> Integer.to_charlist
    |> Path.join(Path.basename(picture.local_url))
    |> String.to_charlist

    {:ok, binary} = File.read(picture.local_url)

    case S3Client.put_object(bucket, path, binary, client) do
      {:error, _} -> bail_s3_upload(pid)
      {:ok, url} -> confirm_s3_upload(pid, picture.id, url)
    end
  end

  defp confirm_s3_upload(pid, picture_id, url) do
    GenServer.cast(pid, {:s3_upload_complete, picture_id, url})
  end

  defp bail_s3_upload(pid) do
    GenServer.cast(pid, {:s3_upload_error, nil})
  end
end
