defmodule Database.Schema do

  def get_schema(dbname, table) do
    q = """
      SELECT column_name, data_type
      FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name   = '#{table}';
    """

    dbuser = ETLConfig.get_config("database", "reader_username")
    dbpass = ETLConfig.get_config("database", "reader_password")

    {:ok, connection} = :epgsql.connect('localhost', to_char_list(dbuser), to_char_list(dbpass),
      [{:database, to_char_list(dbname)}])

    {:ok, _, results} = :epgsql.squery(connection, to_char_list(q))
    :epgsql.close(connection)

    Enum.into(results, %{})
  end

 def call_api(dbname, query, args) do
    dbuser = ETLConfig.get_config("database", "reader_username")
    dbpass = ETLConfig.get_config("database", "reader_password")

    {:ok, connection} = :epgsql.connect('localhost', to_char_list(dbuser), to_char_list(dbpass),
      [{:database, to_char_list(dbname)}])

    {:ok, fields, data} = :epgsql.equery(connection, to_char_list(query), Enum.map(args, fn x -> to_char_list(x) end))

    columns = fields
    |> Enum.map(fn x -> elem(x, 1) end)


    results = data
    |> Enum.map(fn r -> Enum.zip(columns, Tuple.to_list(r)) end)
    |> Enum.map(fn res -> Enum.into(res, %{}) end )

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


end
