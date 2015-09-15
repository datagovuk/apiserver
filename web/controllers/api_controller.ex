defmodule ApiServer.ApiController do
  use ApiServer.Web, :controller

  @doc """
  The theme homepage containing the API UI and information on usage
  """
  def theme(conn, %{"theme"=>theme}=params) do

    # Get the schema for the theme, and assign it to the
    # connection so we can render in template. We can optimize this...
    schemas = Database.Schema.get_schemas(theme)
    host = "http://" <> (System.get_env("HOST") || "localhost:4000")
    manifest = Database.Lookups.find_theme(theme)

    conn
    |> assign(:theme, theme)
    |> assign(:schema, schemas)
    |> assign(:manifest, manifest)
    |> assign(:host, host)
    |> render("theme.html")
  end

  @doc """
  A raw SQL endpoint for the specified theme. The schema should have been
  send as part of the theme action...
  """
  def theme_sql(conn, %{"theme"=>theme, "format"=>"csv"}=params) do
    res = Database.Schema.call_sql_api(theme, params["query"])

    csv_stream = [res["columns"]|res["rows"]] |> CSV.encode

    conn
    |> put_layout(false)
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"query.csv\";")
    |> assign(:csv_stream, csv_stream)
    |> render "csv.html"
  end

  def theme_sql(conn, %{"theme"=>theme}=params) do
    json conn, Database.Schema.call_sql_api(theme, params["query"])
  end

  @doc """
  Calls the actual API endpoint within a theme
  """
  def service(conn, %{"theme"=>theme, "service"=>service, "method"=>method}=params) do
    # Based on theme/service/method we want the sql query, and the parameters to expect
    v = Database.Lookups.find("#{theme}/#{service}/#{method}")
    case process_api_call(params, v) do
      nil ->
          conn |> put_status(400)
      res ->
          json conn, res
    end
  end

  @doc """
  Documentation for the particular service.
  """
  def service_docs(conn, %{"theme"=>theme, "service"=>service}=params) do
    conn
    |> assign(:theme, theme)
    |> assign(:service, service)
    |> render("docs.html")
  end


  @doc false
  defp process_api_call(_, nil) do
    nil
  end

  @doc false
  defp process_api_call(%{"theme"=>theme, "service"=>service, "method"=>method}=params,
                       %{"name"=>param_name, "query"=>query}) do

    parameters = String.split(param_name)
    |> Enum.map(fn p -> Map.get(params, p) end )

    Database.Schema.call_api(theme, query, parameters)
  end


end
