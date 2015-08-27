defmodule Database.Schema do

  defp get_connection(database) do
    dbuser = ETLConfig.get_config("database", "reader_username")
    dbpass = ETLConfig.get_config("database", "reader_password")

    {:ok, connection} = :epgsql.connect('localhost', to_char_list(dbuser), to_char_list(dbpass),
      [{:database, to_char_list(database)}])

    connection
  end

  def get_schemas(dbname) do
    q = """
      SELECT table_name, column_name, data_type
      FROM information_schema.columns
      WHERE table_schema = 'public';
    """

    connection = get_connection(dbname)

    {:ok, _, results} = connection
    |> :epgsql.squery(to_char_list(q))


    data = results
    |> Enum.group_by(fn x->
        elem(x, 0)
       end)
    |> Enum.map( fn {k, v} ->
        cells = Enum.map(v, fn x-> {elem(x, 1), elem(x, 2)} end)
        |> Enum.into(%{})
        IO.inspect cells
        {k, cells}
       end)
    |> Enum.into(%{})

    :epgsql.close(connection)
    data
  end

  def get_schema(dbname, table) do
    q = """
      SELECT column_name, data_type
      FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name   = '#{table}';
    """

    connection = get_connection(dbname)
    {:ok, _, results} = :epgsql.squery(connection, to_char_list(q))
    :epgsql.close(connection)

    Enum.into(results, %{})
  end

 def call_api(dbname, query, args) do

    connection = get_connection(dbname)
    {:ok, fields, data} = :epgsql.equery(connection, to_char_list(query), Enum.map(args, fn x -> to_char_list(x) end))

    columns = fields
    |> Enum.map(fn x -> elem(x, 1) end)

    results = data
    |> Enum.map(fn row ->
      row
      |> Tuple.to_list
      |> Enum.map(fn cell-> clean(cell) end)
      # Turn row into a list
    end)
    |> Enum.map(fn r -> Enum.zip(columns, r) end)
    |> Enum.map(fn res -> Enum.into(res, %{}) end )

#    |> Tuple.to_list
#    |> Enum.map(fn c -> Enum.map(c, fn x-> clean(x) end) end)

    :epgsql.close(connection)

    results
  end

 def call_sql_api(dbname, query) do
    dbuser = ETLConfig.get_config("database", "reader_username")
    dbpass = ETLConfig.get_config("database", "reader_password")

    {:ok, connection} = :epgsql.connect('localhost', to_char_list(dbuser), to_char_list(dbpass),
      [{:database, to_char_list(dbname)}])

    {:ok, _, _} = :epgsql.squery(connection, 'set statement_timeout to 1000;')

    resp = case :epgsql.squery(connection, to_char_list(query)) do
      {:ok, fields, data} ->
        columns = fields
        |> Enum.map(fn x -> elem(x, 1) end)

        results = data
        |> Enum.map(fn r -> Tuple.to_list(r) end)

        %{"columns"=>columns, "rows"=> results, "success" => true }
     {:error, {:error, :error, _, error, _}} ->
        %{"success"=> false, "error" => error}
    {:ok, 1} ->
        %{"success"=> false, "error" => "This is bad"}
    end

    :epgsql.close(connection)
    resp
  end

  defp clean({{year, month, day}, {hr, mn, sec}}) do
    "#{day}/#{month}/#{year} #{hr}:#{mn}:#{sec}"
  end

  defp clean(val) do
     val
  end

end
