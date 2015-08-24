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
    plug :accepts, ["json"]

  end

  scope "/", ApiServer do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/about", PageController, :about

    get "/:theme", ApiController, :theme
    get "/:theme/swagger.json", ApiController, :theme_swagger
    get "/:theme/:service/docs", ApiController, :service_docs
    get "/:theme/:service", ApiController, :service

  end

end
