defmodule ApiServer.PageController do
  use ApiServer.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def about(conn, _params) do
    host = Database.Lookups.find(:general, :host)

    conn
    |> assign(:host, host)
    |> render "about.html"
  end

  def info(conn, _) do
    render conn, "info.html"
  end

  @doc """
  The theme homepage containing the API UI and information on usage
  """
  def theme(conn, %{"theme"=>theme}) do
    ExStatsD.increment("theme.#{theme}.views")

    schema_task = Task.async(fn ()-> Database.Schema.get_schemas(theme) end)

    host = Database.Lookups.find(:general, :host)
    manifest = Database.Lookups.find(:themes, theme)
    distincts = Database.Lookups.find(:distincts, theme)
    filters = Manifest.filter_fields(manifest, theme)

    conn
    |> assign(:theme, theme)
    |> assign(:manifest, manifest)
    |> assign(:distincts, distincts)
    |> assign(:filters, filters)
    |> assign(:host, host)
    |> assign(:schema, Task.await(schema_task))
    |> delete_resp_header("cache-control")
    |> render("theme.html")
  end

end
