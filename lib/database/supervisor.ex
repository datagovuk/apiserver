defmodule Database.Supervisor do
  use Supervisor
  alias Database.Lookups

  def start_link do
    :supervisor.start_link(__MODULE__, %{})
  end

  def init(%{}) do
    # For each theme (database) we need to create a new
    # pool named after the theme.....
    dbuser = ETLConfig.get_config("database", "reader_username")
    dbpass = ETLConfig.get_config("database", "reader_password")
    {port, _} = Integer.parse(System.get_env("PGPORT") || "5432")

    children = :themes
    |> Lookups.find_all
    |> Enum.map(fn {k, _} -> k end)
    |> Enum.map(fn name->
      :poolboy.child_spec(
        String.to_atom(name),
        [
          name: {:local, String.to_atom(name)},
          worker_module: Database.Worker,
          size: 10,
          max_overflow: 10
        ],
        [
          {:dbuser, dbuser},
          {:dbpass, dbpass},
          {:port, port},
          {:database, name},
          {:host, 'localhost'}
        ]
      )
    end)

   supervise(children, strategy: :one_for_one)
  end
end