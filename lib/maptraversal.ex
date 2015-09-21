defmodule MapTraversal do

    @doc"""
    Recursively lookup the key in the provided data.
    The key can be a . separated path through the dict,
    for instance diagnosis.name which will first resolve
    diagnosis, and then resolve name on the result.
    """
    def find_value(key, data) when is_map(data) do
        find(String.split(key, "."), data)
    end

    @doc"""
    Finds the result of looking for key in the map and then
    applies the str_func (to non-list results), or the list_func
    to list results in order to perform comparisons.
    """
    def map_apply(key, map, _value, list_func, str_func) do
        result = find_value key, map
        case result do
          result when is_list(result) ->
            list_func.(result)
          result ->
            str_func.(result)
        end
    end


    defp find([h|t], data) when is_map(data) do
        find t, data[h]
    end

    defp find(k, data) when is_map(data)  do
        data[k]
    end

    defp find([h|_], data) when is_list(data) do
        x = Enum.map data, fn(x) -> find(h, x) end
        # Strip nils, not every item in the list might have the key
        Enum.filter x, fn(x) -> x end
    end

    defp find(_, data) do
        data
    end

end