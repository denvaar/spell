defmodule SpellTest do
  use ExUnit.Case
  doctest Spell

  test "greets the world" do
    assert Spell.hello() == :world
  end
end
