defmodule Phamello.PictureWorker do
  use GenServer
  alias Phamello.{Repo, Picture, PictureTasks}

  # Client

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_picture(%Picture{} = picture) do
    GenServer.cast(__MODULE__, {:s3_upload_start, picture})
  end

  # Server

  def init([]) do
    {:ok, [s3_client]}
  end

  def handle_cast({:s3_upload_start, picture}, state) do
    Task.Supervisor.start_child(
      PictureSupervisor,
      PictureTasks,
      :upload_to_s3,
      [__MODULE__, s3_client, s3_config[:bucket_name], picture]
    )

    {:noreply, state}
  end

  def handle_cast({:s3_upload_complete, picture_id, remote_url}, state) do
    picture = Repo.get!(Picture, picture_id)
    changeset = Picture.update_changeset(picture, %{"remote_url" => remote_url})

    case Repo.update(changeset) do
      {:ok, picture} ->
        IO.puts "Picture updated"
      {:error, changeset} ->
        IO.puts "Picture error"
    end

    {:noreply, state}
  end

  def handle_cast({:s3_upload_error, _}, state) do
    IO.puts("Error uploading to S3")
    {:noreply, state}
  end

  def handle_info(msg, state) do
    IO.puts("Info: #{msg}")
    {:noreply, state}
  end

  defp s3_client do
    :erlcloud_s3.new(
      s3_config[:aws_access_key_id],
      s3_config[:aws_secret_access_key]
    )
  end

  defp s3_config do
    Application.get_env(:phamello, :s3_client)
    |> Enum.map(fn({k, v}) -> {k, String.to_charlist(v)} end)
  end
end
