defmodule Database.Lookups do
  @moduledoc """
  Manifest information about the services provided are stored in
  yaml files, and this module will find the relevant information
  and store it in ETS for fast retrieval.
  """
  alias Poison, as: JSON

  def load_distincts() do
     :ets.new(:distincts, [:named_table])

     "#{Mix.Project.app_path}/priv/static/distincts/*.json"
     |>  Path.wildcard
     |> Enum.each(&load_distinct/1)

  end

  def load_manifests() do
     :ets.new(:services,  [:named_table])
     :ets.new(:themes,    [:named_table])

     path = ETLConfig.get_config("manifest", "location")

     "#{path}/*.yml"
     |> Path.wildcard
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

  defp load_distinct(distincts_file) do
    IO.puts "Loading #{distincts_file}"
    %{"theme"=> theme} = Regex.named_captures(
        ~r/.*\/(?<theme>\w+)\.json/, distincts_file)

    blob = distincts_file
    |> File.read!
    |> JSON.decode!

    :ets.insert(:distincts, {theme, blob})
  end

  defp process_service(service) do
    service_name = service["name"]
    service["searchables"]
    |> Enum.map(fn s->
      sname = s["name"]
      {"#{service_name}/#{sname}", %{"query"=> s["query"],
                                     "name"=>s["name"],
                                     "fields"=>s["fields"]} }
    end)
  end

  @doc """
  Find service by providing the key.
  Choices for type are currently :services or :themes or :distincts
  """
  def find(type, key) do
    case :ets.lookup(type, key) do
      [{^key, bucket}] -> bucket
      [] -> nil
    end
  end

end
