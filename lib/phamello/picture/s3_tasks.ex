defmodule Phamello.S3Tasks do
  alias Phamello.{Picture, S3Client}

  def upload_to_s3(pid, bucket, %Picture{} = picture) do
    remote_path = picture.user_id
    |> Integer.to_char_list
    |> Path.join(Path.basename(picture.local_url))
    |> String.to_charlist

    local_path = Picture.get_local_path(picture)
    {:ok, binary} = File.read(local_path)

    case S3Client.put_object(bucket, remote_path, binary) do
      {:error, _} -> bail_s3_upload(pid, picture.id)
      {:ok, url} -> confirm_s3_upload(pid, picture.id, url)
    end
  end

  defp confirm_s3_upload(pid, picture_id, url) do
    GenServer.cast(pid, {:s3_upload_complete, picture_id, url})
  end

  defp bail_s3_upload(pid, picture_id) do
    GenServer.cast(pid, {:s3_upload_error, picture_id})
  end
end
