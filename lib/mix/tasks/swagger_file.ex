defmodule SwaggerFile do

  def generate([data]) when is_map(data) do
    output = %{}
    |> add_info(data)
    |> add_tags(data)
    |> add_api_endpoints(data)
    |> add_definitions(data)
    output
  end

  defp add_tags(output, data) do
    tags = data["services"]
      |> Enum.map(fn sdict ->  get_tag(sdict) end)
      Dict.put(output, "tags", tags)
  end

  # Converts a service dictionary into a tag dictionary
  defp get_tag(service_dict) do
    %{
        "name" => service_dict["name"],
        "description" => service_dict["description"],
        "externalDocs" => %{
          "description": "External documentation",
          "url": service_dict["documentation_url"]
        }
     }
  end

  defp add_info(output, data) do
    {:ok, hostname} = :inet.gethostname()
    {:ok,{:hostent, fullhost,[],:inet,_,[_]}} = :inet.gethostbyname(hostname)

    root = String.downcase(data["title"])

    output = Dict.put(output, "schemes", ["http"])
    output = Dict.put(output, "swagger", "2.0")
    output = Dict.put(output, "basepath", "/#{root}")
    output = Dict.put(output, "host", to_string(fullhost))

    info = %{
      "description" => data["description"],
      "version" => "1.0.0",
      "title" => data["title"] <> " API",
      "termsOfService" => "",
    }
    Dict.put(output, "info", info)
  end

  defp add_api_endpoints(output, data) do
    svcs = data["services"]
      |> Enum.map(fn sdict -> add_api_endpoint(data["title"], sdict) end)
      |> Enum.into(%{})
    Dict.put(output, "paths", svcs)
  end

  defp add_api_endpoint(theme, service_dict) do
    name = service_dict["name"]
    endpoint = %{
      "tags"=> [service_dict["name"]],
      "security" => [],
      #"summary" => "Find",
      "description" => "TODO",
      "operationId" => "get_#{name}",
      "produces" => [
         "application/xml",
         "application/json",
         "text/csv"
      ],
      "responses" => %{
        "200" => %{
            "description" => "Successful operation",
            "schema" => %{
              "type" => "array",
              "items" => %{"$ref" => "#/definitions/#{name}"}
            }
          },
        "400" => %{
          "description" => "Invalid operation"
        }
      }
    }

    params = service_dict["searchable"]
      |> Enum.map(fn x->  get_parameters(x) end)
    endpoint = Dict.put(endpoint, "parameters", params)

    get = %{"get": endpoint}
    {"/#{String.downcase(theme)}/#{name}", get}
  end

  defp get_parameters(param_dict) do
    %{
      "name" => param_dict["name"],
      "in" => "query",
      "description" => param_dict["description"],
      "required" => false,
      "type" => "string"
     }
  end

  defp add_definitions(output, data) do
    defs = data["services"]
      |> Enum.map(fn sdict -> add_definition(sdict, data["title"]) end)
      |> Enum.into(%{})
    Dict.put(output, "definitions", defs)
  end

  defp add_definition(service_dict, theme) do
    obj = %{
      "type" => "object",
      "properties" => properties_from_db(theme, service_dict),
      "xml" => %{"name": service_dict["name"]}
    }

    {service_dict["name"], obj}
  end

  defp properties_from_db(theme, service_dict) do
    schema = Database.Schema.get_schema(String.downcase(theme), service_dict["name"])
    IO.inspect schema
    property_format(schema)
    |> Enum.into(%{})
  end

  defp property_format(data) do
    x = data
    |> Enum.map( fn {k,v} ->
      {k, %{"type" => "string"}}
    end )
    IO.inspect x
  end


  """

 "Category": {
      "type": "object",
      "properties": {
        "id": {
          "type": "integer",
          "format": "int64"
        },
        "name": {
          "type": "string"
        }
      },
      "xml": {
        "name": "Category"
      }
    },

  """

end