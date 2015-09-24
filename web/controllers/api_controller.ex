defmodule ApiServer.ApiController do
  use ApiServer.Web, :controller
  alias ApiServer.Endpoint, as: Endpoint

  @doc """
  Returns the manifest metadata for the specified theme.
  """
  def info(conn, %{"theme"=>theme}) do
    manifests = :themes
    |> Database.Lookups.find(theme)
    |> get_service_basics

    json conn, manifests
  end


  @doc """
  Returns the manifest metadata for all of the themes
  """
  def info(conn, %{}) do
    manifests = :themes
    |> Database.Lookups.find_all
    |> Enum.map(fn {k, v}->
        {k, get_service_basics(v)}
    end)
    |> Enum.into %{}

    json conn, manifests
  end

  defp get_service_basics(m) do
    m
    |> Dict.get("services")
    |> Enum.map(fn x->
       %{
          "name"=> Map.get(x, "name"),
          "description"=> Map.get(x, "description")
        }
    end)
  end

  @doc """
  A raw SQL endpoint for the specified theme. The schema should have been
  send as part of the theme action...
  """
  def theme_sql(conn, %{"theme"=>theme, "format"=>"csv"}=params) do
    res = Database.Schema.call_sql_api(theme, params["query"])

    Endpoint.broadcast! "info:api", "new:message", %{"theme"=>theme, "query"=>params["query"]}

    ApiServer.Endpoint.broadcast! "info:api", "new:message", %{"theme"=>"environment", "query"=>"something of a long string but hopefully it will fit into the available space but if it doesnt then hopefully iy will wrap cleanly and not make a mess"}

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
    Endpoint.broadcast! "info:api", "new:message", %{"theme"=>theme, "query"=>params["query"]}
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

    Endpoint.broadcast! "info:api", "new:message", %{"theme"=>theme, "query"=> "Basic: #{service}/#{method}"}
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

    Endpoint.broadcast! "info:api", "new:message", %{"theme"=>theme, "query"=> "Basic: #{service}/#{method}"}

    case process_api_call(params, v) do
      nil ->
          conn |> put_status(400)
      res ->
          json conn, res
    end
  end

  @doc """
  Support for querying the endpoint directly by calling it with all of the
  required filters in query params, returned as CSV
  """
  def service_direct(conn, %{"_theme"=>theme, "_service"=>service, "_fmt"=>"csv"}=params) do

    parameters = params
    |> Enum.filter(fn {k, _}-> !String.starts_with?(k, "_")  end)
    |> Enum.filter(fn {_, v}-> String.length(v) > 0  end)
    |> Enum.into %{}

    {query, arguments} = service_direct_query(parameters, service)
    res = Database.Schema.call_api(theme, query, arguments)

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

  @doc """
  Support for querying the endpoint directly by calling it with all of the
  required filters in query params ....
  """
  def service_direct(conn, %{"_theme"=>theme, "_service"=>service}=params) do
    # We want a params dict without theme and service in it ....
    parameters = params
    |> Enum.filter(fn {k, _}-> !String.starts_with?(k, "_")  end)
    |> Enum.filter(fn {_, v}-> String.length(v) > 0  end)
    |> Enum.into %{}

    {query, arguments} = service_direct_query(parameters, service)
    json conn, Database.Schema.call_api(theme, query, arguments)
  end


  defp service_direct_query(parameters, service) do
    qparams = parameters
    |> Enum.with_index
    |> Enum.map(fn {{k, _}, pos} ->
        "#{k}=$#{pos+1} "
    end)
    |> Enum.join( " AND ")

    arguments = parameters
    |> Enum.map(fn {_, v} ->
        v
    end)

    query = "SELECT * FROM #{service} where #{qparams}"
    {query, arguments}
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
  defp process_api_call(_, nil), do: nil
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
