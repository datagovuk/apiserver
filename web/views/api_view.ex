defmodule ApiServer.ApiView do
  use ApiServer.Web, :view

  def capitalize(string) do
    String.capitalize(string)
  end

end
