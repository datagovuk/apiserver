defmodule ApiServer.PageController do

  use ApiServer.Web, :controller
  alias ApiServer.Manifest.Server, as: Manifests

  def index(conn, _params) do
    themes = Manifests.list_themes(:lookup)

    conn
    |> render "index.html", %{:themes => themes}
  end

  def about(conn, _params) do
    conn
    |> render "about.html"
  end

  def info(conn, _) do
    render conn, "info.html"
  end

  def docs(conn, _) do
    conn
    |> render "docs.html"
  end

  @doc """
  The theme homepage containing the API UI and information on usage
  """
  def theme(conn, %{"theme"=>theme}) do
    manifests = Manifests.list_manifests(:lookup, theme)

    case manifests do
      [] ->
        conn
        |> put_status(404)
        |> render "404.html"
      _ ->
        theme_inner(conn, theme, manifests)
    end
  end

  defp theme_inner(conn, theme, manifests) do
    themes = Manifests.list_themes(:lookup)

    schemas = manifests
    |> Enum.map(fn x-> {x.id, x.fields} end)
    |> Enum.into %{}

    distincts = Database.Lookups.find(:distincts, theme)

    conn
    |> delete_resp_header("cache-control")
    |> render("theme.html", %{
      :theme => theme,
      :manifests =>manifests,
      :distincts => distincts,
      :schema => schemas,
      :themes => themes} )
  end

  def service(conn, %{"theme"=>theme, "service"=>service}) do
    conn
    |> render("service.html", %{
       :theme => theme,
       :service_name => service
      })
  end

end
