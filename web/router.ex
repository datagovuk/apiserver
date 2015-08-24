defmodule ApiServer.Router do
  use ApiServer.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json", "application/json"]
    plug Corsica
  end

  scope "/api", ApiServer do
    pipe_through :api

    get "/:theme/sql", ApiController, :theme_sql
    get "/:theme/:service/:method", ApiController, :service
  end

  scope "/", ApiServer do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/about", PageController, :about

    get "/:theme", ApiController, :theme
    get "/:theme/:service/docs", ApiController, :service_docs

  end

end
