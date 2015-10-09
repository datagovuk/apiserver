defmodule ApiServer.Endpoint do
  use Phoenix.Endpoint, otp_app: :api_server

  socket "/socket", ApiServer.UserSocket

  plug Plug.Static,
    at: "/", from: :api_server, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt distincts)

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_api_server_key",
    signing_salt: "QK5QagMn"

  plug ApiServer.Router
end
