defmodule Phamello.PictureWorker do
  use GenServer
  alias Phamello.{Repo, Picture, S3Client, S3Tasks}
  require Logger

  @s3_upload_error_message "Error uploading to S3 with image id:"

  # Client

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_picture(%Picture{} = picture) do
    GenServer.cast(__MODULE__, {:s3_upload_start, picture})
  end

  # Server

  def init([]) do
    {:ok, [S3Client.new]}
  end

  def handle_cast({:s3_upload_start, picture}, state) do
    [client] = state

    Task.Supervisor.start_child(
      PictureSupervisor,
      S3Tasks,
      :upload_to_s3,
      [__MODULE__, client, S3Client.bucket, picture]
    )

    {:noreply, state}
  end

  def handle_cast({:s3_upload_complete, picture_id, remote_url}, state) do
    picture = Repo.get!(Picture, picture_id)
    changeset = Picture.update_changeset(picture, %{"remote_url" => remote_url})

    case Repo.update(changeset) do
      {:ok, _picture} -> :ok
      {:error, _changeset} ->
        Logger.error "#{@s3_upload_error_message} #{picture_id}"
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
end
