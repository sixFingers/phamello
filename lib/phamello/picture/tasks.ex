defmodule Phamello.PictureTasks do
  alias Phamello.Picture

  def upload_to_s3(pid, s3_client, bucket, %Picture{} = picture) do
    path = picture.user_id
    |> Integer.to_charlist
    |> Path.join(Path.basename(picture.local_url))
    |> String.to_charlist

    {:ok, binary} = File.read(picture.local_url)

    case :erlcloud_s3.put_object(bucket, path, binary, s3_client) do
      {:aws_error, _} -> bail_s3_upload(pid)
      _ -> confirm_s3_upload(pid, picture.id, bucket, path)
    end
  end

  defp confirm_s3_upload(pid, picture_id, bucket, path) do
    remote_url = "https://#{bucket}.s3.amazonaws.com/#{path}"
    GenServer.cast(pid, {:s3_upload_complete, picture_id, remote_url})
  end

  defp bail_s3_upload(pid) do
    GenServer.cast(pid, {:s3_upload_error, nil})
  end
end
