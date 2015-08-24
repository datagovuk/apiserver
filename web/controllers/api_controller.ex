defmodule ApiServer.ApiController do
  use ApiServer.Web, :controller

  @doc """
  The theme homepage containing the swagger UI and information
  """
  def theme(conn, %{"theme"=>theme}=params) do
    conn
    |> assign(:theme, theme)
    |> render("theme.html")
  end

  @doc """
  Returns the swagger.json for the specified theme.
  """
  def theme_swagger(conn, %{"theme"=>theme}=params) do
    conn
    |> assign(:theme, theme)
    |> render("theme.html")
  end

  @doc """
  Calls the actual API endpoint within a theme
  """
  def service(conn, %{"theme"=>theme, "service"=>service}=params) do
    conn
    |> assign(:theme, theme)
    |> render("theme.html")
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

end
