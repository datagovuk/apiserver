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
      WHERE table_schema = 'public' AND
      table_name NOT in (    'geography_columns',
            'geometry_columns',
            'raster_columns',
            'raster_overviews',
            'spatial_ref_sys')
    """
    pool = String.to_atom(dbname)

    {:ok, result} = :poolboy.transaction(pool, fn(worker)->
      Worker.query(worker, q)
    end, @timeout)

    result.rows
    |> Enum.group_by(fn x->
          hd(x)
        end)
    |> Enum.map( fn {k, v} ->
        vals = Enum.map(v, fn val-> tl(val) end)
        {k, vals}
        end)
    |> Enum.into %{}
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

    {:ok, results} = :poolboy.transaction(pool, fn(worker)->
       Worker.query(worker, q)
    end, @timeout)

    x  = results.rows |> Enum.map(fn [k,v] ->  {k, v} end) |>Enum.into(%{})
    IO.inspect x
    x
  end

 def call_api(dbname, query, arguments \\ []) do

    pool = String.to_atom(dbname)

    results = :poolboy.transaction(pool, fn(worker)->
       Worker.query(worker, query, arguments)
    end, @timeout)

    case results do
      {:ok, result} ->
          columns = result.columns
          results = result.rows
          |> Enum.map(fn row ->
            row
            |> Enum.map(fn cell-> clean(cell) end)
          end)
          |> Enum.map(fn r -> Enum.zip(columns, r) end)
          |> Enum.map(fn res -> Enum.into(res, %{}) end )
      {:error, error} ->
          error
    end
  end

 def call_sql_api(dbname, query) do

    pool = String.to_atom(dbname)

    :poolboy.transaction(pool, fn(worker)->
      {:ok, _} = Worker.query(worker, 'set statement_timeout to 5000;')

     resp = case Worker.query(worker, query)  do
          {:ok, result} ->
            results = result.rows
            |> Enum.map(fn row ->
              row
              |> Enum.map(fn cell-> clean(cell) end)
            end)
            |> Enum.map(fn r -> Enum.zip(result.columns, r) end)
            |> Enum.map(fn res -> Enum.into(res, %{}) end )

            %{"success"=> true, "result" => results}
          {:error, error} ->
            %{"success"=> false, "error" => Postgrex.Error.message(error)}
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
      Worker.query(worker, q)
    end)

    case plan do
      {:ok, results} ->
        data = results.rows
        |> List.flatten
        |> hd

        node_type = MapTraversal.find_value("Plan.Node Type", data) |> String.downcase
        plan_rows = MapTraversal.find_value("Plan.Plan Rows", data)

        {node_type=="limit", plan_rows}
      {:error, _} ->
        # This will fail further on
        {true, 0}
    end
 end

  defp clean(%Postgrex.Timestamp{}=ts) do
    "#{ts.day}/#{ts.month}/#{ts.year} #{filled_int(ts.hour)}:#{filled_int(ts.min)}:#{filled_int(ts.sec)}"
  end
  defp clean(val), do: val

  defp filled_int(i) when i < 10 do
    "0#{i}"
  end

  defp filled_int(i) do
    "#{i}"
  end

end
