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

  def docs(conn, _) do
    host = Database.Lookups.find(:general, :host)
    conn
    |> assign(:host, host)
    |> render "docs.html"
  end


  @doc """
  The theme homepage containing the API UI and information on usage
  """
  def theme(conn, %{"theme"=>theme}) do
    manifest = Database.Lookups.find(:themes, theme)
    case manifest do
      nil ->
        conn
        |> put_status(404)
        |> render "404.html"
      _ ->
        theme_inner(conn, theme, manifest)
    end
  end

  defp theme_inner(conn, theme, manifest) do
    ExStatsD.increment("theme.#{theme}.views")

    schema_task = Task.async(fn ()-> Database.Schema.get_schemas(theme) end)

    host = Database.Lookups.find(:general, :host)
    distincts = Database.Lookups.find(:distincts, theme)
    filters = Manifest.filter_fields(manifest, theme)

    # TODO: Get distincts, filters and schema from the JSON endpoint
    # as and when required.  Want to only really send theme, manifest and
    # host here.
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
