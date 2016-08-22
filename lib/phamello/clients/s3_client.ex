defmodule Phamello.S3Client do
  def new do
    :erlcloud_s3.new(
      config[:aws_access_key_id],
      config[:aws_secret_access_key]
    )
  end

  def put_object(bucket, path, binary, client) do
    case :erlcloud_s3.put_object(bucket, path, binary, client) do
      {:aws_error, _} -> {:error, nil}
      _ -> {:ok, remote_image_url(bucket, path)}
    end
  end

  def bucket, do: config[:bucket_name]

  def config do
    Application.get_env(:phamello, __MODULE__)
    |> Enum.map(fn({k, v}) ->
      v = case v do
        nil -> ""
        _ -> String.to_charlist(v)
      end

      {k, v}
    end)
  end

  defp remote_image_url(bucket, path), do:
    "https://#{bucket}.s3.amazonaws.com/#{path}"
end
