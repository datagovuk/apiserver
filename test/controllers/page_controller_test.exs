defmodule ApiServer.PageControllerTest do
  use ApiServer.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "DGU API"
  end
end
