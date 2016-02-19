defmodule ApiServer.PageController do

  use ApiServer.Web, :controller
  alias ApiServer.Manifest.Server, as: Manifests

  def index(conn, _params) do
    themes = Manifests.list_themes(:lookup)

    conn
    |> render "index.html", %{:themes => themes}
  end

  def theme_page(conn, %{"theme"=>theme}) do
    themes = Manifests.list_themes(:lookup)
    manifests = Manifests.list_manifests(:lookup, theme)
    conn
    |> render "theme.html", %{
        :manifests => manifests,
        :theme => theme,
        :themes => themes
    }
  end

  def service(conn, %{"theme"=>theme, "service" => service}) do
    themes = Manifests.list_themes(:lookup)
    manifest = Manifests.get_manifest(:lookup, theme, service)

    IO.inspect manifest

    conn
    |> render "service.html", %{
        :manifest => manifest,
        :theme => theme,
        :themes => themes
    }
  end


end
