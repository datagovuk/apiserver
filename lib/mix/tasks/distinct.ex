defmodule Mix.Tasks.Distinct do

  defmodule Generate do
    use Mix.Task
    alias Poison, as: JSON

    @shortdoc "Generate distinct fields for a table"

    @moduledoc """
      A task for generating distinct fields for a table for
      filtered search
    """

    @doc """
    Runs the task, and require the theme name for the manifest to
    be loaded and processed.
    """
    def run([]), do: IO.puts "ERROR: The name of the manifest is required!"
    def run([theme]) do
      :application.start(:gproc)
      :application.start(:econfig)
      :application.start(:yaml_elixir)
      :application.start(:yamerl)

      ini_path = System.get_env("DGU_ETL_CONFIG")
      :econfig.register_config(:inifile, [to_char_list(ini_path)], [])

      ymlfile = "manifest"
      |> ETLConfig.get_config("location")
      |> Path.join("#{theme}.yml")

      IO.puts "Attempting to load #{ymlfile}"
      data = YamlElixir.read_from_file(ymlfile)

      res = process_services(data["services"],
                             String.downcase(data["title"]),
                             %{})

      path = "#{Mix.Project.app_path}/priv/static/distincts/#{theme}.json"

      :ok = File.write!(path, JSON.encode!(res))
      IO.puts "Wrote distincts file to #{path}"

      :application.stop(:econfig)
      :application.stop(:gproc)
      :application.stop(:yamerl)
      :application.stop(:yaml_elixir)
    end


    defp process_services([h|t], theme, acc) do
      results = process_service(h, theme)
      acc = Dict.put(acc, h["name"], results)
      process_services(t, theme, acc)
    end
    defp process_services([], _, acc), do: acc


    defp process_service(service_dict, theme_name) do
      service_dict["table_settings"]
      |> process_table_settings(theme_name, service_dict["name"])
    end


    defp process_table_settings(table_settings, theme_name, name) do
      table_settings
      |> Dict.get("choice_fields", [])
      |>  process_choice_field(theme_name, name, %{})
    end


    defp process_choice_field([h|t], theme_name, name, acc) do
      dbuser = ETLConfig.get_config("database", "owner")
      dbpass = ETLConfig.get_config("database", "owner")

      {port, _} = Integer.parse(System.get_env("PGPORT") || "5432")

      {:ok, connection} = :epgsql.connect('localhost',
                                          to_char_list(dbuser),
                                          to_char_list(dbpass),
        [{:database, to_char_list(theme_name)}, {:port, port}])

      {:ok, _, results} = connection
      |> :epgsql.squery(to_char_list("select distinct(#{h}) from #{name};"))

      sorted = results
      |> Enum.map(&extract_val/1)
      |> Enum.sort

      :epgsql.close(connection)

      process_choice_field(t, theme_name, name, Dict.put(acc, h, sorted))
    end

    defp process_choice_field([], _, _, acc), do: acc
    defp process_choice_field(nil, _, _, acc), do: acc

    defp extract_val({val}), do: val

  end
end
