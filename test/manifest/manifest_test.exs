defmodule ApiServer.ManifestTest do
  use ExUnit.Case
  alias ApiServer.Manifest.Server

  setup_all context do
    {:ok, pid} = Server.start_link(path: "./test/data/")
    {:ok, %{:server => pid}}
  end

  test "can list themes", context do
    themes = Server.list_themes(context.server)
    assert length(themes) == 2
  end

  test "can list manifests for theme", context do
    manifests = Server.list_manifests(context.server, "health")
    assert length(manifests) == 2
  end

  test "can load manifests for theme/by name", context do
    manifest = Server.get_manifest(context.server, "health", "clinics")
    refute manifest == nil
  end

end
