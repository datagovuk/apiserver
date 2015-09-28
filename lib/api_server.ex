defmodule ApiServer do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    ini_path = System.get_env("DGU_ETL_CONFIG")
    if ini_path == nil do
      IO.puts "DGU_ETL_CONFIG is not defined"
      System.halt(1)
    end
    :ok = :econfig.register_config(:inifile, [to_char_list(ini_path)], [])

    # Load the manifests into ETS before the supervisors start ...
    Database.Lookups.load

    children = [
      supervisor(ApiServer.Endpoint, []),
      supervisor(Database.Supervisor, []),
      worker(Stats, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ApiServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ApiServer.Endpoint.config_change(changed, removed)
    :ok
  end
end
