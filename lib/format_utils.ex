defmodule ApiServer.Format.Utils do

  @doc """
    Clean up various types for output either as JSON or with a specified fmt
  """
  def clean(%Postgrex.Timestamp{}=ts, _) do
    "#{ts.day}/#{ts.month}/#{ts.year} #{filled_int(ts.hour)}:#{filled_int(ts.min)}:#{filled_int(ts.sec)}"
  end
  def clean(%Geo.Point{}=point, nil), do:  Geo.JSON.encode(point)
  def clean(%Geo.Point{}=point, fmt) do
    comma_join_latlng(point.coordinates)
  end
  def clean(val, _), do: val

  def comma_join_latlng({a, b}), do: "#{b},#{a}"

  @doc """
    Converts numbers less than 10 to a two digit number.
  """
  def filled_int(i) when i < 10 do
    "0#{i}"
  end
  def filled_int(i), do: "#{i}"

  @doc """
    Flattens a map down to a string
  """
  def flatten_tabular(m) when is_map(m) do
    Poison.encode!(m)
  end
  def flatten_tabular(v), do: v

  @doc """
    Converts the provided field to the specified type
  """
  def convert("", _), do: ""
  def convert(field, "float") do
      case Float.parse(field) do
        {val, _} -> val
        :error -> ""
      end
  end
  def convert(field, "integer") do
      case Integer.parse(field) do
        {val, _} -> val
        :error -> ""
      end
  end
  def convert(field, "string"), do: field

end