defmodule Phamello.PictureController do
  use Phamello.Web, :controller
  use Guardian.Phoenix.Controller
  alias Phamello.{Picture, PictureUploader, PictureWorker}
  import Ecto

  plug Guardian.Plug.EnsureResource,
      handler: Phamello.AuthController

  plug Guardian.Plug.EnsureAuthenticated,
      handler: Phamello.AuthController

  def index(conn, _params, user, _claims) do
    query = from p in Picture,
      join: u in assoc(p, :user),
      where: u.id == ^(user.id),
      order_by: [desc: p.updated_at]

    pictures = Repo.all(query)
    render(conn, "index.html", pictures: pictures)
  end

  def new(conn, _params, _user, _claims) do
    changeset = Picture.insert_changeset(%Picture{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"picture" => picture_params}, user, _claims) do
    changeset = build_assoc(user, :pictures)
    |> Picture.create_changeset(picture_params)

    case Repo.insert(changeset) do
      {:ok, picture} ->
        PictureWorker.handle_picture(picture)

        conn
        |> put_flash(:info, "Picture created successfully.")
        |> redirect(to: picture_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user, _claims) do
    picture = Repo.get!(assoc(user, :pictures), id)
    PictureWorker.remove_picture(picture)
    Repo.delete!(picture)

    conn
    |> put_flash(:info, "Picture deleted successfully.")
    |> redirect(to: picture_path(conn, :index))
  end
end
