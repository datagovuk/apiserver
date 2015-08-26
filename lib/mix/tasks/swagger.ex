defmodule Mix.Tasks.Swagger do

  defmodule Generate do
    use Mix.Task

    @shortdoc "Generate swagger file from manifest"

    @moduledoc """
      A task for generating a swagger file from the ETL manifest
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
      ok = :econfig.register_config(:inifile, [to_char_list(ini_path)], [])

      #[theme] = args
      ymlfile = ETLConfig.get_config("manifest", "location") |> Path.join("#{theme}.yml")
      IO.puts "Attempting to load #{ymlfile}"

      data = YamlElixir.read_from_file(ymlfile)

      output = SwaggerFile.generate([data])
      {:ok, data} = Poison.encode_to_iodata(output, [indent: 4])

      :ok = File.write("priv/static/swagger/#{theme}.json", data)

      IO.puts "Wrote JSON file to priv/static/swagger/#{theme}.json"

      :application.stop(:econfig)
      :application.stop(:gproc)
      :application.stop(:yamerl)
      :application.stop(:yaml_elixir)
    end


  end

end