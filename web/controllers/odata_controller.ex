defmodule ApiServer.ODataController do
  use ApiServer.Web, :controller
  alias Database.Lookups

  def index(conn, _params) do
    themes =  Lookups.find_all(:themes)
    |> Map.keys()
    |> Enum.sort

    conn
    |> assign(:themes, themes)
    |> render("index.html")
  end

  def root(conn, %{"theme"=>theme}) do
    # Generate root document for the theme tables ....
  end

end
