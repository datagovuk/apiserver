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
    plug :accepts, ["", "json", "application/json", "ttl", "application/x-turtle", "csv"]
    plug Corsica
    plug :allow_jsonp
  end

  scope "/service", ApiServer do
    pipe_through :api

    get "/", ApiController, :info
    get "/status", ApiController, :status
#     get "/:theme", ApiController, :info
#
#     get "/:theme/distinct", ApiController, :distinct
#     get "/:theme/distinct/:service", ApiController, :distinct
#
     get "/:theme/sql", ApiController, :theme_sql
#     get "/:theme/:service/:method", ApiController, :service
#     get "/:_theme/:_service", ApiController, :service_direct

  end

  scope "/", ApiServer do
    pipe_through :browser

    get "/", PageController, :index
    get "/:theme/:service", PageController, :service
    get "/:theme", PageController, :theme_page

#    get "/about", PageController, :about
#    get "/documentation", PageController, :docs
#    get "/stream", PageController, :info

#    get "/odata", ODataController, :index
#    get "/odata/service", ODataController, :service
#    get "/odata/service/:theme", ODataController, :root

#    get "/:theme", PageController, :theme
#    get "/:theme/:service", PageController, :service
#    get "/:theme/:service/docs", PageController, :service_docs
  end


end
