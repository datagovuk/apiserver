defmodule Database.Lookups do
  @moduledoc """
  Manifest information about the services provided are stored in
  yaml files, and this module will find the relevant information
  and store it in ETS for fast retrieval.
  """
  alias Poison, as: JSON

  def load do
    load_manifests
    load_distincts
    load_general
  end

  def load_general() do
    :ets.new(:schema_cache, [:named_table, read_concurrency: true])
    :ets.new(:general, [:named_table, read_concurrency: true])
  end

  def load_distincts() do
     :ets.new(:distincts, [:named_table, read_concurrency: true])

     "#{Mix.Project.app_path}/priv/static/distincts/*.json"
     |>  Path.wildcard
     |> Enum.each(&load_distinct/1)

  end

  def load_manifests() do
     :ets.new(:services,  [:named_table, read_concurrency: true])
     :ets.new(:themes,    [:named_table, read_concurrency: true])

     path = ETLConfig.get_config("manifest", "location")

     "#{path}/*.yml"
     |> Path.wildcard
     |> Enum.each(fn x-> load_single_manifest(x) end)
  end

  defp load_single_manifest(filepath) do
    data = YamlElixir.read_from_file(filepath)

    theme = String.downcase(data["title"])
    if theme == "internal" do
        nil
    else
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
  end

  defp load_distinct(distincts_file) do
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
                                     "fields"=>s["fields"],
                                     "large_dataset"=>Map.get(s,"large_dataset", false)} }
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

  def find_all(type) do
    type
    |> :ets.tab2list
    |> Enum.into %{}
  end

end
