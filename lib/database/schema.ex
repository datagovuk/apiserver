defmodule Database.Schema do
  @moduledoc """
  This module contains all of the functions used to connect to the
  database for performing queries, and also fetching schema of tables.
  """
  alias Database.Worker
  alias Poison, as: JSON

  @timeout 6000

  def get_schemas(dbname) do
    # TODO: Cache this in :schema_cache ...

    q = """
      SELECT table_name, column_name, data_type
      FROM information_schema.columns
      WHERE table_schema = 'public';
    """
    pool = String.to_atom(dbname)

    {:ok, _, results} = :poolboy.transaction(pool, fn(worker)->
      Worker.query(worker, q)
    end, @timeout)

    results
    |> Enum.group_by(fn x->
        elem(x, 0)
       end)
    |> Enum.map( fn {k, v} ->
        cells = Enum.map(v, fn x-> {elem(x, 1), elem(x, 2)} end)
        |> Enum.into(%{})
        {k, cells}
       end)
    |> Enum.into(%{})
  end

  def get_schema(dbname, table) do
    # TODO: Cache this in :schema_cache ...

    q = """
      SELECT column_name, data_type
      FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name   = '#{table}';
    """
    pool = String.to_atom(dbname)

    {:ok, _, results} = :poolboy.transaction(pool, fn(worker)->
       Worker.query(worker, q)
    end, @timeout)

    results |> Enum.into(%{})
  end

 def call_api(dbname, query, arguments \\ []) do

    # ExStatsD.increment("query.#{dbname}.apicall")

    args = Enum.map(arguments, fn x -> to_char_list(x) end)
    pool = String.to_atom(dbname)

    results = :poolboy.transaction(pool, fn(worker)->
       Worker.query(worker, query, args)
    end, @timeout)

    case results do
      {:ok, fields, data} ->
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
      _ ->
        results
    end
  end

 def call_sql_api(dbname, query) do

    # ExStatsD.increment("query.#{dbname}.sqlcall")

    pool = String.to_atom(dbname)

    :poolboy.transaction(pool, fn(worker)->
      {:ok, _, _} = Worker.query(worker, 'set statement_timeout to 5000;')

     resp = case Worker.raw_query(worker, query)  do
          {:ok, fields, data} ->
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

            %{"success"=> true, "result" => results}
         {:error, {:error, :error, _, error, _}} ->
            %{"success"=> false, "error" => error}
         {:ok, 1} ->
            %{"success"=> false, "error" => "This is bad"}
        end
    end, @timeout)
   end


  @doc """
  For a given query, will check whether it is limited and whether
  it is less than 500 rows.  Returns
  { true, 500 } - Limit of 500
  { true, 1000 } - Limit of 1000
  { false, 0 } - No limit
  """
  def check_query_limit(theme, query) do
    q = "EXPLAIN (format json) #{query}"
    pool = String.to_atom(theme)
    plan = :poolboy.transaction(pool, fn(worker)->
       case Worker.raw_query(worker, q) do
        {:error, _} -> nil
        {:ok, _, [{plan}]} -> plan
      end
    end)

    case plan do
      nil ->
        # This will fail further one
        {true, 0}
      _ ->
        [data] = JSON.decode! plan
        node_type = MapTraversal.find_value("Plan.Node Type", data) |> String.downcase
        plan_rows = MapTraversal.find_value("Plan.Plan Rows", data)

        {node_type=="limit", plan_rows}
    end
 end

  defp clean({{year, month, day}, {hr, mn, sec}}) do
    "#{day}/#{month}/#{year} #{filled_int(hr)}:#{filled_int(mn)}:#{filled_int(sec)}"
  end

  defp clean(val) do
     val
  end

  defp filled_int(i) when i < 10 do
    "0#{i}"
  end

  defp filled_int(i) do
    "#{i}"
  end

end
