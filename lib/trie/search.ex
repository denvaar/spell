defmodule Spell.Trie.Search do
  def word_exists?(nil, _word), do: false
  def word_exists?(trie, ""), do: trie.terminal

  def word_exists?(node, <<first_letter::binary-size(1), rest_of_letters::binary>>) do
    node.children
    |> Map.get(first_letter)
    |> word_exists?(rest_of_letters)
  end

  def prefix_exists?(nil, _prefix), do: false
  def prefix_exists?(_trie, ""), do: true

  def prefix_exists?(node, <<first_letter::binary-size(1), rest_of_letters::binary>>) do
    node.children
    |> Map.get(first_letter)
    |> prefix_exists?(rest_of_letters)
  end
end
