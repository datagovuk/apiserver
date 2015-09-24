defmodule ApiServer.UserSocket do
  use Phoenix.Socket

  channel "info:*", ApiServer.InfoChannel

  transport :websocket, Phoenix.Transports.WebSocket

  def connect(_params, socket) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
