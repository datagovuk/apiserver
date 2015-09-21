defmodule ApiServer.ApiView do
  use ApiServer.Web, :view


  def capitalize(string) do
    string
    |>  String.capitalize
  end

  def first_key(m) when is_map(m) do
    k = hd(Map.keys(m))
    String.downcase(k)
  end

  # Helpers for working with manifest ....
  def services(manifest) do
    manifest
    |> Dict.get("services")
    |> Enum.map(fn s -> {Dict.get(s, "name"),
                         Dict.get(s, "description"),
                         Dict.get(s,"documentation")} end)
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
