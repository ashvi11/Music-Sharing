defmodule FSTest do
  use ExUnit.Case
  doctest FS

  test "greets the world" do
    assert FS.hello() == :world
  end
end
