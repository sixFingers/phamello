defmodule Phamello.PictureController do
  use Phamello.Web, :controller
  use Guardian.Phoenix.Controller
  alias Phamello.{Picture, PictureUploader, PictureWorker}

  plug Guardian.Plug.EnsureAuthenticated,
      handler: __MODULE__

  def index(conn, _params, user, _claims) do
    pictures = Repo.all(Picture)
    render(conn, "index.html", pictures: pictures)
  end

  def new(conn, _params, user, _claims) do
    changeset = Picture.changeset(%Picture{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"picture" => picture_params}, user, _claims) do
    changeset = Picture.changeset(%Picture{user: user}, picture_params)
    changeset = changeset |> PictureUploader.with_local_storage

    case Repo.insert(changeset) do
      {:ok, picture} ->
        # PictureWorker.handle_picture(picture)

        conn
        |> put_flash(:info, "Picture created successfully.")
        |> redirect(to: picture_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user, _claims) do
    picture = Repo.get!(Picture, id)
    render(conn, "show.html", picture: picture)
  end

  def edit(conn, %{"id" => id}, user, _claims) do
    picture = Repo.get!(Picture, id)
    changeset = Picture.changeset(picture)
    render(conn, "edit.html", picture: picture, changeset: changeset)
  end

  def update(conn, %{"id" => id, "picture" => picture_params}, user, _claims) do
    picture = Repo.get!(Picture, id)
    changeset = Picture.changeset(picture, picture_params)

    case Repo.update(changeset) do
      {:ok, picture} ->
        conn
        |> put_flash(:info, "Picture updated successfully.")
        |> redirect(to: picture_path(conn, :show, picture))
      {:error, changeset} ->
        render(conn, "edit.html", picture: picture, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user, _claims) do
    picture = Repo.get!(Picture, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(picture)

    conn
    |> put_flash(:info, "Picture deleted successfully.")
    |> redirect(to: picture_path(conn, :index))
  end

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> put_flash(:error, "Authentication required")
    |> redirect(to: "/")
  end
end
