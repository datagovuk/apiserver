defmodule ApiServer.ApiView do
  use ApiServer.Web, :view
  alias Poison, as: JSON

  def decode_possible_point(%{"coordinates"=>coord}) do
    coord
    |> Enum.reverse
    |> Enum.join(",")
  end
  def decode_possible_point(p), do: p

  def hash_for_map(m) do
    JSON.encode!(m)
    |> :erlang.md5
    |> Base.encode16(case: :lower)
  end

  def ttl_terminator({k, _}, object) do
    vals = object |> Enum.into([])
    pos = length(Dict.keys(object)) - 1

    if pos == Enum.find_index(vals, fn({x, _}) -> x == k end) do
      "."
    else
      ";"
    end
  end
end
