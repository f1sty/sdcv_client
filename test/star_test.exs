defmodule StarTest do
  use ExUnit.Case
  doctest Star

  test "greets the world" do
    assert Star.hello() == :world
  end
end
