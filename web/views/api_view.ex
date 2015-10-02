defmodule ApiServer.ApiView do
  use ApiServer.Web, :view
  alias Poison, as: JSON

  def hash_for_map(m) do
    JSON.encode!(m)
    |> :erlang.md5
    |> Base.encode16(case: :lower)
  end

  def ttl_terminator({k, v}, object) do
    vals = object |> Enum.into([])
    pos = length(Dict.keys(object)) - 1

    if pos == Enum.find_index(vals, fn({x,y}) -> x == k end) do
      "."
    else
      ";"
    end
  end
end
