defmodule Phamello.PictureWorker do
  use GenServer
  alias Phamello.{Repo, Picture, S3Client, S3Tasks, TrelloTasks}
  require Logger

  @s3_upload_error_message "Error uploading to S3 with image id:"
  @trello_notify_error_message "error pushing to Trello image with id:"
  @picture_remove_error_message "error when removing image with id:"

  # Client

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def handle_picture(%Picture{} = picture) do
    GenServer.cast(__MODULE__, {:s3_upload_start, picture})
  end

  def remove_picture(%Picture{} = picture) do
    GenServer.cast(__MODULE__, {:picture_remove, picture})
  end

  # Server

  def init([]) do
    {:ok, []}
  end

  def handle_cast({:s3_upload_start, picture}, state) do
    Task.Supervisor.start_child(
      PictureSupervisor,
      S3Tasks,
      :upload_to_s3,
      [__MODULE__, S3Client.bucket, picture]
    )

    {:noreply, state}
  end

  def handle_cast({:s3_upload_complete, picture_id, remote_url}, state) do
    picture = Picture |> Repo.get!(picture_id) |> Repo.preload(:user)
    changeset = Picture.update_changeset(picture, %{"remote_url" => remote_url})

    case Repo.update(changeset) do
      {:ok, _picture} ->
        GenServer.cast(__MODULE__, {:trello_notify_start, picture})
      {:error, _changeset} ->
        Logger.error "#{@s3_upload_error_message} #{picture_id}"
    end

    {:noreply, state}
  end

  def handle_cast({:s3_upload_error, picture_id}, state) do
    Logger.error "Error uploading to S3 image with id: #{picture_id}"
    {:noreply, state}
  end

  def handle_cast({:trello_notify_start, %Picture{} = picture}, state) do
    Task.Supervisor.start_child(
      PictureSupervisor,
      TrelloTasks,
      :push_to_board,
      [__MODULE__, picture]
    )

    {:noreply, state}
  end

  def handle_cast({:trello_notify_complete, picture_id, card_url}, state) do
    picture = Picture |> Repo.get!(picture_id) |> Repo.preload(:user)
    changeset = Picture.update_changeset(picture, %{"trello_url" => card_url})
    {status, _changeset} = Repo.update(changeset)

    if status == :error do
      Logger.error "#{@s3_upload_error_message} #{picture_id}"
    end

    {:noreply, state}
  end

  def handle_cast({:trello_notify_error, picture_id, error}, state) do
    Logger.error "#{error} #{@trello_notify_error_message} #{picture_id}"
    {:noreply, state}
  end

  def handle_cast({:picture_remove, picture}, state) do
    result = File.rm(Picture.get_local_path(picture))

    if result != :ok do
      {:error, reason} = result
      Logger.error "#{reason} #{@picture_remove_error_message} #{picture.id}"
    end

    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.info msg
    {:noreply, state}
  end
end
