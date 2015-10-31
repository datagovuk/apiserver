defmodule ApiServer.Manifest.Server do
  use GenServer
  alias ApiServer.Manifest.Theme
  alias ApiServer.Manifest.Manifest

  def start_link(options) do
    GenServer.start_link(__MODULE__, options)
  end

  def list_themes(pid) do
    GenServer.call(pid, {:list_all, :theme_objects})
  end

  def list_manifests(pid, theme) do
    GenServer.call(pid, {:list_all, :manifest_objects})
  end

  def get_manifest(pid, theme, name) do
    GenServer.call(pid, {:find_manifest, theme_manifest_key(theme, name)})
  end

  def theme_manifest_key(theme, manifest) do
    "#{theme}/#{manifest}"
  end

  ######################################################################
  # Genserver callbacks ..
  ######################################################################

  def init(state) do
      root = Keyword.get(state, :path)
      case root do
        nil -> nil
        r ->
          load_themes(Path.join([r, "themes", "*.json"]))
          load_manifests(Path.join([r, "manifests", "*.json"]))
      end
      {:ok, state}
  end

  def handle_call({:list_all, key}, _from, state) do
    items = key
    |> :ets.tab2list
    |> Enum.into []
    {:reply, items, state}
  end

  def handle_call({:find_manifest, key}, _from, state) do
    result = case :ets.lookup(:manifest_objects, key) do
      [{^key, bucket}] -> bucket
      [] -> nil
    end
    {:reply, result, state}
  end


  ######################################################################
  # Helpers
  ######################################################################

  defp load_themes(path) do
    Path.wildcard(path)
    |> Enum.map(fn file->
         theme = File.read!(file)
          |> Poison.decode!( as: Theme)

          :ets.insert(:theme_objects, {theme.id, theme})
    end)
  end

  defp load_manifests(path) do
    Path.wildcard(path)
    |> Enum.map(fn file->
         IO.inspect file
         manifest = File.read!(file)
          |> Poison.decode!( as: Manifest)

          key = theme_manifest_key(manifest.theme, manifest.id)
          :ets.insert(:manifest_objects, {key, manifest})
    end)
  end



end