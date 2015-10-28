defmodule ApiServer.PageControllerTest do
  use ApiServer.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "Data.gov.uk - API Server"
  end
end
