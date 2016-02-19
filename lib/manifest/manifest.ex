
defmodule ApiServer.Manifest.Manifest do
  @moduledoc """
  Models a manifest that is loaded from a manifest JSON file.
  """
  defstruct id: "", description: "", dataset: "", geo: false, theme: "",
    title: "", tablename: "", fields: [], choice_fields: [], queries: []

end
