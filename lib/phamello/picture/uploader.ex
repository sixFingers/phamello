defmodule Phamello.PictureUploader do
  alias Ecto.Changeset

  @persistence_error_message "Couldn't persist the image on local storage"

  def with_local_storage(changeset) do
    case changeset.valid? do
      false -> changeset
      true -> persist_image(changeset)
    end
  end

  defp persist_image(changeset) do
    image = Changeset.get_field(changeset, :image)
    path = image_path(changeset)
    path |> Path.dirname() |> File.mkdir_p()

    case File.copy(image.path, path) do
      {:ok, _bytes} -> changeset
        |> Changeset.put_change(:local_url, path)
        |> Changeset.apply_changes
      {:error, _reason} -> changeset
        |> Changeset.add_error(:image, @persistence_error_message)
    end
  end

  defp image_path(changeset) do
    user = Changeset.get_field(changeset, :user)
    image = Changeset.get_field(changeset, :image)
    timestamp = current_timestamp()
    rootname = Path.rootname(image.filename)
    extension = Path.extname(image.filename)

    image_path = config[:storage_path]
    |> Path.join("#{user.id}")
    |> Path.join(rootname)

    "#{image_path}_#{timestamp}#{extension}"
  end

  defp current_timestamp do
    {{y, m, d}, {h, mm, s}} = :calendar.universal_time
    "#{y}#{m}#{d}_#{h}#{mm}#{s}"
  end

  defp config, do: Application.get_env(:phamello, __MODULE__)
end
