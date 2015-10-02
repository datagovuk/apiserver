defmodule ApiServer.ApiView do
  use ApiServer.Web, :view
  alias Poison, as: JSON

  def hash_for_map(m) do
    JSON.encode!(m)
    |> :erlang.md5
    |> Base.encode16(case: :lower)
  end

end
