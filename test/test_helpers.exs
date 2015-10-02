defmodule ApiServer.HelperTest do
  use ExUnit.Case

  test "can find last element in comprehension" do

    mydict = %{"first"=>"element", "last"=>"value"}
    assert ApiServer.ApiView.ttl_terminator({"last","value"}, mydict) == "."
    assert ApiServer.ApiView.ttl_terminator({"first","element"}, mydict) == ";"
  end


end
