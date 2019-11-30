defmodule Spell.Trie do
  @enforce_keys [:letter, :children, :terminal]

  defstruct(
    letter: nil,
    children: %{},
    terminal: false
  )

  defdelegate insert(trie, word), to: Spell.Trie.Insertion
  defdelegate word_exists?(trie, word), to: Spell.Trie.Search
  defdelegate prefix_exists?(trie, prefix), to: Spell.Trie.Search
end
