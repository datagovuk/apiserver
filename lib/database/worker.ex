defmodule Database.Worker do
  use GenServer
  @timeout 6000

  @moduledoc """
  Contains a connection to the database and handles running queries.
  Each of these servers is managed by the Pool in supervisor
  """

  def start_link(args\\[]) do
    arguments = args |> Enum.into %{}
    GenServer.start_link(__MODULE__, arguments)
  end

  def query(pid, query, args \\ []) do
      try do
        # The database connection should time out before this call
        GenServer.call(pid, {:query, query, args}, :infinity)
      catch
        _ -> {:error, "The query took too long to run"}
      end
  end


  ######################################################################
  # Genserver callbacks ..
  ######################################################################
  def init(arguments) do
    # Create a connection to the database ...
    {:ok, pid} = Postgrex.Connection.start_link(
        hostname: arguments.host,
        username: arguments.dbuser,
        password: arguments.dbpass,
        database: arguments.database,
        port: arguments.port,
        extensions: [{Postgrex.Extensions.JSON, library: Poison},
                            {Geo.PostGIS.Extension, library: Geo}])
    {:ok, pid}
  end

  def handle_call({:query, query, arguments}, _from, connection) do
    Postgrex.Connection.query!(connection, "set statement_timeout to 5000;", [])
    results = Postgrex.Connection.query(connection, query, arguments, [timeout: @timeout])
    {:reply, results, connection}
  end

  def handle_call({:slow_query, query, arguments}, _from, connection) do
    Postgrex.Connection.query!(connection, "set statement_timeout to 10000;", [])
    results = Postgrex.Connection.query(connection, query, arguments, [timeout: @timeout*2])
    {:reply, results, connection}
  end


  def terminate(_reason, connection) do
    Postgrex.Connection.stop(connection)
    :ok
  end


end
