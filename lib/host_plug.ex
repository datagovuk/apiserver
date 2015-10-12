defmodule ApiServer.HostPlug do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    first_two = conn.path_info |> Enum.take 2
    case first_two == ["data", "api"] do
      true ->
          %{conn | path_info: Enum.drop(conn.path_info, 2)}
       _ ->
          conn
    end
  end
end