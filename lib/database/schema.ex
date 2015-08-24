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


end
