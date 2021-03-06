defmodule ApiServer.PageView do
  use ApiServer.Web, :view
  alias Poison, as: JSON


  def has_map(manifests) do
    manifests |> Enum.any?(fn x->x.geo end)
  end

  def default_value(field) do
    field |> Map.get(:default, "")
  end


  def get_host(conn) do
    host_url(conn.host, conn.port)
  end
  defp host_url(host, 80), do: "//#{host}"
  defp host_url(host, port), do: "//#{host}:#{port}"

  def to_js_list(items) do
    JSON.encode!(items)
  end

def prettify(nil), do: ""
  def prettify("lat"), do: "Latitude"
  def prettify("lon"), do: "Longitude"
  def prettify(word) do

    word
    |> String.replace("_", " ")
    |> String.replace("-", " ")
    |> String.replace("lat", "latitude")
    |> String.replace("lon", "longitude")
    |> String.split(" ")
    |> Enum.map(fn w-> capitalize(w) end)
    |> Enum.join(" ")
  end

  def capitalize(string) do
    string
    |>  String.capitalize
  end

  def first_key(m) when is_map(m) do
    k = hd(Map.keys(m))
    String.downcase(k)
  end

  def is_dangerous(manifest, service) do
    svc = manifest
    |> Dict.get("services")
    |> Enum.filter(fn f-> Dict.get(f, "name") == service end)

    if length(svc) > 0 do
      svc
      |> hd
      |> Dict.get("large_dataset", false)
    else
      false
    end
  end

  def has_geo_data(manifest) do
    # FIXME
    false
  end

  # Helpers for working with manifest ....
  def services(manifest) do
    manifest
    |> Dict.get("services")
    |> Enum.map(fn s -> {Dict.get(s, "name"),
                         Dict.get(s, "description"),
                         Dict.get(s,"documentation"),
                         Dict.get(s, "dataset", "")} end)
    |> Enum.sort
  end

  def searchables_for_service(manifest, service_name) do
    searchables = manifest
    |> Dict.get("services")
    |> Enum.filter_map(fn f-> Dict.get(f, "name") == service_name end,
                       fn s -> Dict.get(s, "searchables") end)
    |> Enum.map(fn items ->
        Enum.map(items, fn f ->
          [
            Dict.get(f, "name"),
            Dict.get(f, "description"),
            Dict.get(f, "fields")
          ]
        end)
    end)
    hd searchables
  end

end
