defmodule ApiServer.ODataController do
  use ApiServer.Web, :controller
  alias ApiServer.Manifest.Server, as: Manifests

  def index(conn, _params) do
    themes = Manifests.list_themes(:lookup)
    |> Enum.map(fn x-> x.id end)

    conn
    |> assign(:themes, themes)
    |> render("index.html")
  end

  def service(conn, %{}) do
    themes = Manifests.list_themes(:lookup)

    conn
    |> assign(:themes, themes)
    |> render("service.xml")
  end

  def root(conn, %{"theme"=>theme}=params) do
    top = Map.get(params, "$top")

    conn
    |> assign(:collection, theme)
    |> assign(:entries, [%{:fields => [{"wombles","Edm.Bool", ""}]}])    
    |> render("root.xml")
  end

end
