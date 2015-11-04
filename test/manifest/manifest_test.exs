defmodule ApiServer.ManifestTest do
  use ExUnit.Case
  alias ApiServer.Manifest.Server

  setup_all _context do
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
    assert manifest.id == "clinics"
    assert manifest.tablename == "clinics"
    assert length(manifest.fields) > 0
    assert length(manifest.queries) > 0
  end

  test "manifests do not need queries", context do
    manifest = Server.get_manifest(context.server, "health", "dentists")
    assert manifest.queries == []
  end

end
