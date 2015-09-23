defmodule ApiServer.PageController do
  use ApiServer.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def about(conn, _params) do
    host = "http://" <> (System.get_env("HOST") || "localhost:4000")
    conn
    |> assign(:host, host)
    |> render "about.html"
  end

  @doc """
  The theme homepage containing the API UI and information on usage
  """
  def theme(conn, %{"theme"=>theme}) do

    # Get the schema for the theme, and assign it to the
    # connection so we can render in template. We can optimize this...
    schemas = Database.Schema.get_schemas(theme)
    host = "http://" <> (System.get_env("HOST") || "localhost:4000")
    manifest = Database.Lookups.find(:themes, theme)
    distincts = Database.Lookups.find(:distincts, theme)
    filters = Manifest.filter_fields(manifest, theme)

    conn
    |> assign(:theme, theme)
    |> assign(:schema, schemas)
    |> assign(:manifest, manifest)
    |> assign(:distincts, distincts)
    |> assign(:filters, filters)
    |> assign(:host, host)
    |> render("theme.html")
  end

end
