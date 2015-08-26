defmodule ApiServer do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Start the endpoint when the application starts
      supervisor(ApiServer.Endpoint, []),
      # Here you could define other workers and supervisors as children
      # worker(ApiServer.Worker, [arg1, arg2, arg3]),
    ]

    ini_path = System.get_env("DGU_ETL_CONFIG")
    ok = :econfig.register_config(:inifile, [to_char_list(ini_path)], [])

    Database.Lookups.load_manifests

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
