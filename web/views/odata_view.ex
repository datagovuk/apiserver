defmodule ApiServer.ODataView do
  use ApiServer.Web, :view
  alias ApiServer.PageView

  defdelegate prettify(word), to: PageView
  defdelegate get_host(conn), to: PageView

end
