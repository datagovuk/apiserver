
defmodule Manifest do
  @moduledoc """
  Models a manifest that is loaded from a manifest JSON file.
  """
  defstruct dbname: "", tablename: "", fields: [], choice_fields: [], searchables: []


  def filter_fields(manifest, theme) do
    manifest
    |> Dict.get("services")
    |> Enum.map(fn service->
      {Dict.get(service, "name"),
       MapTraversal.find_value("table_settings.filter_fields", service)}
    end)
    |> Enum.into %{}
  end

end
