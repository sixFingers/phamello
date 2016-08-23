defmodule Phamello.S3Client do
  def put_object(bucket, path, binary) do
    request = ExAws.S3.put_object(bucket, "/#{path}", binary)

    case ExAws.request(request) do
      {:ok, _} -> {:ok, remote_image_url(bucket, path)}
      _ -> {:error, nil}
    end
  end

  def bucket, do: System.get_env("IMAGE_STORAGE_BUCKET")

  defp remote_image_url(bucket, path), do:
    "https://#{bucket}.s3.amazonaws.com/#{path}"
end
