defmodule Stats do
  use GenServer

  @moduledoc """
  Provides a way of streaming logs of usage and stats to
  a websocket/file
  """

  def start_link(args\\[]) do
    GenServer.start_link(__MODULE__, [], [name: :stats])
  end

  def log(pid, url) do
    GenServer.cast(pid, {:log, url})
  end


  ######################################################################
  # Genserver callbacks ..
  ######################################################################
  def init([]) do
    {:ok, []}
  end

  def handle_cast({:log, url}, state) do

    {:noreply, state}
  end


end
