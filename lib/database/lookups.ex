defmodule Database.Lookups do

  def load_manifests() do
     :ets.new(:services, [:named_table])
     :ets.new(:themes,   [:named_table])

     path = ETLConfig.get_config("manifest", "location")

     Path.wildcard("#{path}/*.yml")
     |> Enum.each(fn x-> load_single_manifest(x) end)

  end

  defp load_single_manifest(filepath) do
    data = YamlElixir.read_from_file(filepath)

    theme = String.downcase(data["title"])
    :ets.insert(:themes, {theme, data})

    data["services"]
    |> Enum.map(fn x-> process_service(x) end)
    |> List.flatten
    |> Enum.into(%{})
    |> Enum.each(fn s->
      {k, v} = s
      :ets.insert(:services, {"#{theme}/#{k}", v})
    end)
  end

  defp process_service(service) do
    service_name = service["name"]
    service["searchables"]
    |> Enum.map(fn s->
      sname = s["name"]
      {"#{service_name}/by_#{sname}", %{"query"=> s["query"], "name"=>s["name"]} }
    end)
  end

  def find(key) do
    case :ets.lookup(:services, key) do
      [{^key, bucket}] -> bucket
      [] -> nil
    end
  end

  def find_theme(key) do
    case :ets.lookup(:themes, key) do
      [{^key, bucket}] -> bucket
      [] -> nil
    end
  end

end