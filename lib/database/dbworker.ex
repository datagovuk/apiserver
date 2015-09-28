defmodule Database.Worker do
  use GenServer

  @moduledoc """
  Contains a connection to the database and handles running queries.
  Each of these servers is managed by the Pool in supervisor
  """

  def start_link(args\\[]) do
    arguments = args |> Enum.into %{}

    {:ok, connection} = :epgsql.connect(arguments.host,
                                        to_char_list(arguments.dbuser),
                                        to_char_list(arguments.dbpass),
      [{:database, to_char_list(arguments.database)},
       {:port, arguments.port}
      ])

    GenServer.start_link(__MODULE__, connection)
  end

  def raw_query(pid, query, args \\ []) do
    GenServer.call(pid, {:rawquery, to_char_list(query), args})
  end


  def query(pid, query, args \\ []) do
    GenServer.call(pid, {:query, to_char_list(query), args})
  end

  ######################################################################
  # Genserver callbacks ..
  ######################################################################
  def init(connection) do
    # Create a connection to the database ...
    :epgsql.squery(connection, 'set statement_timeout to 3000;')
    {:ok, connection}
  end

  def terminate(_reason, connection) do
    :epgsql.close(connection)
    :ok
  end

  def handle_call({:rawquery, query, []}, _from, connection) do
    result = :epgsql.squery(connection, to_char_list(query))
    {:reply, result, connection}
  end

  def handle_call({:rawquery, query, arguments}, _from, connection) do
    results = :epgsql.equery(connection, to_char_list(query),
                                         Enum.map(arguments,
                                            fn x -> to_char_list(x) end))

    {:reply, results, connection}
  end


  def handle_call({:query, query, []}, _from, connection) do
    {:ok, fields, data} = :epgsql.squery(connection, to_char_list(query))
    {:reply, {:ok, fields, data}, connection}
  end

  def handle_call({:query, query, arguments}, _from, connection) do
    {:ok, fields, data} = :epgsql.equery(connection, to_char_list(query),
                                         Enum.map(arguments,
                                            fn x -> to_char_list(x) end))

    {:reply, {:ok, fields, data}, connection}
  end

end
