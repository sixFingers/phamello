defmodule Guardian.Plug.EnsureResource do
  def init(opts), do: opts

  def call(conn, _opts) do
    case conn.private[:guardian_default_resource] do
      nil -> handle_error(conn)
      _ -> conn
    end
  end

  defp handle_error(%Plug.Conn{} = conn) do
    Guardian.Plug.sign_out(conn)
  end
end
