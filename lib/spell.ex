defmodule Spell do
  alias Spell.Trie

  def load_words(path) do
    {:ok, content} = File.read(path)

    content
    |> String.split("\n")
    |> insert_many(nil)
  end

  def load_words_async(path) do
    # read file and format contents
    {:ok, content} = File.read(path)

    content
    |> split_content_into_words()
    |> group_words_by_first_letter()
    |> spawn_tasks_for_each_group()
    |> await_and_merge_into_trie()
  end

  def insert_many([], trie), do: trie

  def insert_many([word | rest_of_words], trie) do
    insert_many(
      rest_of_words,
      Spell.Trie.insert(trie, word)
    )
  end

  defp await_and_merge_into_trie(tasks) do
    root = %Trie{letter: nil, children: %{}, terminal: false}

    Enum.reduce(tasks, root, fn task, trie ->
      sub_trie = Task.await(task)
      %{trie | children: Map.merge(trie.children, sub_trie.children)}
    end)
  end

  defp spawn_tasks_for_each_group(groups) do
    groups
    |> Enum.map(fn group_of_words ->
      Task.async(fn -> insert_many(group_of_words, nil) end)
    end)
  end

  defp group_words_by_first_letter(words) do
    words
    |> Enum.reduce(%{}, fn <<first_letter::binary-size(1), _rest::binary>> = word, groups ->
      Map.put(groups, first_letter, [word | Map.get(groups, first_letter, [])])
    end)
    |> Map.values()
  end

  def split_content_into_words(content) do
    content
    |> String.trim("\n")
    |> String.split("\n")
  end
end
