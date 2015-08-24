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

      ini_path = System.get_env("DGU_ETL_CONFIG")
      ok = :econfig.register_config(:inifile, [String.to_char_list(ini_path)], [])

      #[theme] = args
      ymlfile = ETLConfig.get_config("manifest", "location") |> Path.join("#{theme}.yml")
      IO.puts "Attempting to load #{ymlfile}"
      {:ok, data} = Yomel.decode_file(ymlfile)

      output = SwaggerFile.generate(data)
      IO.puts Poison.encode!(output, [])

      :application.stop(:econfig)
      :application.stop(:gproc)
    end


  end

end