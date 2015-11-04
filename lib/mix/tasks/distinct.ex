defmodule Mix.Tasks.Distinct do

  defmodule Generate do
    use Mix.Task
    alias Poison, as: JSON
    alias ApiServer.Manifest.Manifest

    @shortdoc "Generate distinct fields for a table"

    @moduledoc """
      A task for generating distinct fields for a table for
      filtered search
    """

    @doc """
    Runs the task, and require the theme name for the manifest to
    be loaded and processed.
    """
    def run([]), do: IO.puts "ERROR: The name of the theme is required!"
    def run([theme]) do
      :application.start(:postgrex)
      manifest_path = System.get_env("MANIFESTS")

      manifests = Path.wildcard(Path.join([manifest_path, "manifests/*.json"]))
      |> Enum.map(fn file->
         File.read!(file)
          |> Poison.decode!( as: Manifest, keys: :atoms)
      end)
      |> Enum.filter( fn m->
          m.theme == theme
      end)

      res = process_services(manifests, theme, %{})

      IO.inspect res

      path = Path.join([manifest_path, "distincts/#{theme}.json" ])
      :ok = File.write!(path, JSON.encode!(res))
      IO.puts "Wrote distincts file to #{path}"

      :application.stop(:postgrex)
    end


    defp process_services([h|t], theme, acc) do
      results = process_service(h, theme)
      acc = Dict.put(acc, h.id, results)
      process_services(t, theme, acc)
    end
    defp process_services([], _, acc), do: acc


    defp process_service(manifest, theme_name) do
      manifest
      |> process_table_settings(theme_name, manifest.id)
    end


    defp process_table_settings(manifest, theme_name, name) do
      manifest.choice_fields
      |> process_choice_field(theme_name, name, %{})
    end


    defp process_choice_field([h|t], theme_name, name, acc) do
      dbuser = System.get_env("DBUSER")
      dbpass = System.get_env("DBPASS")

      {port, _} = Integer.parse(System.get_env("PGPORT") || "5432")


     {:ok, connection} = Postgrex.Connection.start_link(hostname: "localhost",
                                                                 username: dbuser,
                                                                 password: dbpass,
                                                                 database: "apiserver",
                                                                 port: port)


     {:ok, results} = Postgrex.Connection.query(connection, "select distinct(#{h}) from #{name} order by #{h};", [])
      Postgrex.Connection.stop(connection)

      res = results.rows
      |> List.flatten
      |> Enum.map(fn x-> String.strip(x) end)

      process_choice_field(t, theme_name, name, Dict.put(acc, h, res))
    end

    defp process_choice_field([], _, _, acc), do: acc
    defp process_choice_field(nil, _, _, acc), do: acc

    defp extract_val({val}), do: val

  end
end
