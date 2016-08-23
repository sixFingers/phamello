defmodule Phamello.PictureView do
  use Phamello.Web, :view

  def picture_image_url(conn, picture) do
    path = Path.join("/images", picture.local_url)
    static_url(conn, path)
  end
end
