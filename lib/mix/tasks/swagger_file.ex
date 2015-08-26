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

  defp get_host("dev") do
    "127.0.0.1:4000"
  end

  defp get_host("prod") do
    System.get_env("HOST")
  end

  defp add_info(output, data) do
    root = String.downcase(data["title"])

    output = Dict.put(output, "schemes", ["http"])
    output = Dict.put(output, "swagger", "2.0")
    output = Dict.put(output, "basepath", "/api")


    output = Dict.put(output, "host", get_host(System.get_env("MIX_ENV")))

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
      |> List.flatten
      |> Enum.into(%{})

    Dict.put(output, "paths", svcs)
  end

  defp add_api_endpoint(theme, service_dict) do
    Enum.map(service_dict["searchables"], fn s ->
        add_searchable_endpoint( theme, service_dict, s)
    end)
  end

  defp add_searchable_endpoint(theme, service_dict, searchable) do
    service_name = service_dict["name"]
    name = searchable["name"]
    endpoint = %{
      "tags"=> [service_dict["name"]],
      "security" => [],
      #"summary" => "Find",
      "description" => searchable["description"],
      "operationId" => "get_#{service_name}_#{name}",
      "produces" => [
         #"application/xml",
         "application/json",
         #"text/csv"
      ],
      "responses" => %{
        "200" => %{
            "description" => "Successful operation",
            "schema" => %{
              "type" => "array",
              "items" => %{"$ref" => "#/definitions/#{service_name}"}
            }
          },
        "400" => %{
          "description" => "Invalid operation"
        }
      }
    }

    endpoint = Dict.put(endpoint, "parameters", get_parameters(searchable))
    get = %{"get": endpoint}
    {"/api/#{String.downcase(theme)}/#{service_name}/by_#{name}", get}
  end

  defp get_parameters(param_dict) do
    [%{
          "name" => param_dict["name"],
          "in" => "query",
          "description" => "",
          "required" => true,
          "type" => "string"
         }]
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
    property_format(schema)
    |> Enum.into(%{})
  end

  defp property_format(data) do
    data
    |> Enum.map( fn {k,v} ->
      {k, %{"type" => "string"}}
    end )
  end


end