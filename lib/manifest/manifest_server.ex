defmodule ApiServer.Manifest.Server do
  use GenServer
  alias ApiServer.Manifest.Theme

  def start_link(options) do
    GenServer.start_link(__MODULE__, options)
  end

  def list_themes(pid) do
    GenServer.call(pid, {:list_all, :theme_objects})
  end

  def list_manifests(pid, theme) do
    []
  end

  def get_manifest(pid, theme, name) do
    []
  end

  def theme_manifest_key(theme, manifest) do
    "#{theme}/#{manifest}"
  end

  ######################################################################
  # Genserver callbacks ..
  ######################################################################

  def init(state) do
      root = Keyword.get(state, :path)

      load_themes(Path.join([root, "themes", "*.json"]))

      {:ok, state}
  end

  def handle_call({:list_all, key}, _from, state) do
    items = key
    |> :ets.tab2list
    |> Enum.into []
    {:reply, items, state}
  end



  defp load_themes(path) do
    Path.wildcard(path)
    |> Enum.map(fn file->
         theme = File.read!(file)
          |> Poison.decode!( as: Theme)

          :ets.insert(:theme_objects, {theme.id, theme})
    end)
  end




end