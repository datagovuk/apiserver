defmodule Database.Schema do
  @moduledoc """
  This module contains all of the functions used to connect to the
  database for performing queries, and also fetching schema of tables.
  """
  alias Database.Worker
  alias Poison, as: JSON
  alias ApiServer.Format.Utils

  def get_schemas(service_list) do
    # TODO: Cache this in :schema_cache ...

    names = service_list
    |> Enum.map(fn s->
          "'#{s}'"
        end)
    |> Enum.join(",")

    q = """
      SELECT table_name, column_name, data_type
      FROM information_schema.columns
      WHERE table_schema = 'public' AND
      table_name in ( #{names})
    """

    {:ok, result} = :poolboy.transaction(:apiserver, fn(worker)->
      Worker.query(worker, q)
    end)

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

  def get_schema(table) do
    # TODO: Cache this in :schema_cache ...

    q = """
      SELECT column_name, data_type
      FROM information_schema.columns
      WHERE table_schema = 'public'
        AND table_name   = '#{table}';
    """
    {:ok, results} = :poolboy.transaction(:apiserver, fn(worker)->
       Worker.query(worker, q)
    end)

    results.rows |> Enum.map(fn [k,v] ->  {k, v} end) |>Enum.into(%{})
  end

 def call_api( query, arguments, options \\ []) do

    fmt = Keyword.get(options, :format)

    results = :poolboy.transaction(:apiserver, fn(worker)->
       Worker.query(worker, query, arguments)
    end)

    case results do
      {:ok, result} ->
          columns = result.columns
          results = result.rows
          |> Enum.map(fn row ->
            row
            |> Enum.map(fn cell-> Utils.clean(cell, fmt) end)
          end)
          |> Enum.map(fn r -> Enum.zip(columns, r) end)
          |> Enum.map(fn res -> Enum.into(res, %{}) end )
      {:error, error} ->
          {:error, error}
    end
  end

 def call_sql_api(query, options \\ []) do
    check_query_performance(query) |> call_sql_api_inner(query, options)
end

def call_sql_api_inner(true, _, _) do
    %{"success"=> false, "error" => "Query would take too long to run, please apply a LIMIT of less than 5000 rows"}
end
def call_sql_api_inner(_, query, options \\ []) do
    fmt = Keyword.get(options, :format)
    :poolboy.transaction(:apiserver, fn(worker)->
     resp = case Worker.query(worker, query)  do
          {:ok, result} ->
            results = result.rows
            |> Enum.map(fn row ->
              row
              |> Enum.map(fn cell-> Utils.clean(cell, fmt) end)
            end)
            |> Enum.map(fn r -> Enum.zip(result.columns, r) end)
            |> Enum.map(fn res -> Enum.into(res, %{}) end )

            %{"success"=> true, "result" => results}
          {:error, error} ->
            %{"success"=> false, "error" => Postgrex.Error.message(error)}
        end
    end)
   end


  @doc """
  For a given query, will check whether it is likely to run slowly
  """
  def check_query_performance(query) do
    q = "EXPLAIN (format json) #{query}"

    plan = :poolboy.transaction(:apiserver, fn(worker)->
      Worker.query(worker, q)
    end)

    case plan do
      {:ok, results} ->
        data = results.rows
        |> List.flatten
        |> hd

        node_type = MapTraversal.find_value("Plan.Node Type", data)
        cost = MapTraversal.find_value("Plan.Total Cost", data)

        slow?(node_type, cost )
      {:error, _} ->
        # This will fail further on
        :ok
    end
 end

  def slow?("Limit", cost) when cost > 1000, do: true
  def slow?("Seq Scan", cost) when cost > 1000, do: true
  def slow?("Seq Scan", _), do: false
  def slow?(_, _), do: false

  @doc """
  For a given query, will check whether it is limited and whether
  it is less than 500 rows.  Returns
  { true, 500 } - Limit of 500
  { true, 1000 } - Limit of 1000
  { false, 0 } - No limit
  """
  def check_query_limit(query) do
    q = "EXPLAIN (format json) #{query}"

    plan = :poolboy.transaction(:apiserver, fn(worker)->
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

end
