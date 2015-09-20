defmodule ApiServer.ApiController do
  use ApiServer.Web, :controller

  @doc """
  The theme homepage containing the API UI and information on usage
  """
  def theme(conn, %{"theme"=>theme}) do

    # Get the schema for the theme, and assign it to the
    # connection so we can render in template. We can optimize this...
    schemas = Database.Schema.get_schemas(theme)
    host = "http://" <> (System.get_env("HOST") || "localhost:4000")
    manifest = Database.Lookups.find(:themes, theme)

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
    |> put_resp_header("content-disposition",
                       "attachment; filename=\"query.csv\";")
    |> assign(:csv_stream, csv_stream)
    |> render "csv.html"
  end

  def theme_sql(conn, %{"theme"=>theme}=params) do
    json conn, Database.Schema.call_sql_api(theme, params["query"])
  end

  @doc """
  Calls the actual API endpoint within a theme
  """
  def service(conn, %{"theme"=>theme, "service"=>service,
                      "method"=>method, "format"=>"csv"}=params) do
    # Based on theme/service/method we want the sql query, and the
    # parameters to expect
    v = Database.Lookups.find(:services, "#{theme}/#{service}/#{method}")

    res = process_api_call(params ,v)

    schema = Map.keys(Database.Schema.get_schema(theme, service))

    rows = Enum.map(res, fn m ->
      Map.values(m)
    end)

    csv_stream = [schema|rows] |> CSV.encode

    conn
    |> put_layout(false)
    |> put_resp_content_type("text/csv; charset=utf-8")
    |> put_resp_header("content-disposition",
                       "attachment; filename=\"query.csv\";")
    |> assign(:csv_stream, csv_stream)
    |> render "csv.html"

  end

  def service(conn, %{"theme"=>theme, "service"=>service,
                      "method"=>method}=params) do
    # Based on theme/service/method we want the sql query,
    # and the parameters to expect
    v = Database.Lookups.find(:services, "#{theme}/#{service}/#{method}")

    case process_api_call(params, v) do
      nil ->
          conn |> put_status(400)
      res ->
          json conn, res
    end
  end

  @doc """
  Support for querying the endpoint directly by calling it with all of the
  required filters in query params ....
  """
  def service_direct(conn, %{"theme"=>theme, "service"=>service}=params) do
    # We want a params dict without theme and service in it ....

  end


  @doc """
  Documentation for the particular service.
  """
  def service_docs(conn, %{"theme"=>theme, "service"=>service}=_params) do
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
  defp process_api_call(%{"theme"=>theme}=params,
                       %{"query"=>query, "fields"=>fields}) do

    parameters = case fields do
      nil -> []
      _ -> Enum.map(fields, fn f ->
             Map.get(params, f)
           end)
    end
    Database.Schema.call_api(theme, query, parameters)
  end


end
