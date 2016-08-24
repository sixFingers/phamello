defmodule Phamello.UserSocket do
  use Phoenix.Socket
  # import Guardian.Phoenix.Socket

  channel "user:*", Phamello.UserChannel

  transport :websocket, Phoenix.Transports.WebSocket
  # transport :longpoll, Phoenix.Transports.LongPoll

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
