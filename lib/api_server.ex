defmodule ApiServer do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    :ets.new(:theme_objects, [:named_table, :public, read_concurrency: true])
    :ets.new(:manifest_objects, [:named_table, :public, read_concurrency: true])


    manifest_path = System.get_env("MANIFESTS")

    children = [
      supervisor(ApiServer.Endpoint, []),
      supervisor(Database.Supervisor, []),
      worker(ApiServer.Manifest.Server, [[path: manifest_path]])
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
