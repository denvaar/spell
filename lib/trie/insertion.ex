defmodule Spell.Trie.Insertion do
  alias Spell.Trie

  def insert(nil, word), do: insert(leaf_node(nil), word)
  def insert(trie, ""), do: %Trie{trie | terminal: true}

  def insert(
        trie,
        <<first_letter::binary-size(1), rest_of_letters::binary>> = _word
      ) do
    %Trie{
      letter: trie.letter,
      children: update_children(trie, first_letter, rest_of_letters),
      terminal: trie.terminal
    }
  end

  defp update_children(node, first_letter, remaining_letters) do
    Map.put(
      node.children,
      first_letter,
      insert(next_child(node.children, first_letter), remaining_letters)
    )
  end

  defp next_child(children, first_letter) do
    children
    |> get_or_create_node(first_letter)
  end

  defp get_or_create_node(children, key) do
    case Map.get(children, key) do
      nil -> leaf_node(key)
      child_node -> child_node
    end
  end

  defp leaf_node(letter) do
    %Trie{letter: letter, children: %{}, terminal: false}
  end
end
