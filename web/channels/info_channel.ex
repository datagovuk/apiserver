defmodule ApiServer.InfoChannel do
  use Phoenix.Channel

  def join("info:api", %{}, socket) do
    send(self, :after_join)
    {:ok, socket}
  end

  def terminate(_, socket) do
    send(self, :after_leave)
    {:ok}
  end

  def handle_info(:after_join, socket) do
    broadcast! socket, "user:joined", %{}
    {:noreply, socket}
  end

  def handle_info(:after_leave, socket) do
    broadcast! socket, "user:left", %{}
    {:noreply, socket}
  end


end