defmodule ApiServer.ApiView do
  use ApiServer.Web, :view


  def capitalize(string) do
    String.capitalize(string)
  end

  def first_key(m) when is_map(m) do
    k = hd(Map.keys(m))
    String.downcase(k)
  end

end
