defmodule ApiServer.ApiController do
  use ApiServer.Web, :controller

  @doc """
  The theme homepage containing the swagger UI and information
  """
  def theme(conn, %{"theme"=>theme}=params) do

    # Get the schema for the theme, and assign it to the
    # connection so we can render in template. We can optimize this...
    schemas = %{
      "hospitals" => Database.Schema.get_schema(theme, "hospitals" ),
      "clinics"   => Database.Schema.get_schema(theme, "clinics" ),
    }

    conn
    |> assign(:theme, theme)
    |> assign(:schema, schemas)
    |> render("theme.html")
  end

  @doc """
  A raw SQL endpoint for the specified theme. The schema should have been
  send as part of the theme action...
  """
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
