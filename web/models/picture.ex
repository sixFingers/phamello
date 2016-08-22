defmodule Phamello.Picture do
  use Phamello.Web, :model

  @persistence_error_message "Couldn't persist the image on local storage"
  @size_error_message "Image is too big"

  schema "pictures" do
    field :name, :string
    field :description, :string
    field :local_url, :string
    field :remote_url, :string
    field :trello_url, :string
    field :image, :any, virtual: true

    belongs_to :user, Phamello.User

    timestamps()
  end

  def insert_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :image])
    |> validate_required([:name, :description, :image])
  end

  def create_changeset(struct, params \\ %{}) do
    changeset = insert_changeset(struct, params)

    case changeset.valid? do
      false -> changeset
      true -> validate_image(changeset)
    end
  end

  def update_changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:remote_url, :trello_url])
  end

  defp validate_image(changeset) do
    image = get_field(changeset, :image)

    case validate_upload_size(image) do
      true -> persist_image(changeset)
      false -> changeset
        |> add_error(:image, @size_error_message)
    end
  end

  defp validate_upload_size(%Plug.Upload{} = image) do
    {:ok, stats} = File.stat(image.path)
    stats.size <= config[:max_file_size]
  end

  defp persist_image(changeset) do
    image = get_field(changeset, :image)
    path = image_path(changeset)
    path |> Path.dirname() |> File.mkdir_p()

    case File.copy(image.path, path) do
      {:ok, _bytes} -> changeset
        |> put_change(:local_url, path)
        |> apply_changes
      {:error, _reason} -> changeset
        |> add_error(:image, @persistence_error_message)
    end
  end

  defp image_path(changeset) do
    user_id = get_field(changeset, :user_id)
    image = get_field(changeset, :image)
    timestamp = current_timestamp()
    rootname = Path.rootname(image.filename)
    extension = Path.extname(image.filename)

    image_path = config[:storage_path]
    |> Path.join("#{user_id}")
    |> Path.join(rootname)

    "#{image_path}_#{timestamp}#{extension}"
  end

  defp current_timestamp do
    {{y, m, d}, {h, mm, s}} = :calendar.universal_time
    "#{y}#{m}#{d}_#{h}#{mm}#{s}"
  end

  defp config, do: Application.get_env(:phamello, __MODULE__)
end
