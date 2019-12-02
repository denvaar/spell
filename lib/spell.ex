defmodule Spell do
  alias Spell.Trie

  def load_words(path) do
    {:ok, content} = File.read(path)

    content
    |> String.split("\n")
    |> insert_many(nil)
  end

  def insert_many([], trie), do: trie

  def insert_many([word | rest_of_words], trie) do
    insert_many(
      rest_of_words,
      Spell.Trie.insert(trie, word)
    )
  end

  def load_words_async(path) do
    root = %Trie{letter: nil, children: %{}, terminal: false}
    # read file and format contents
    {:ok, content} = File.read(path)

    content
    |> words_from_content()
    |> Enum.reduce(%{}, fn <<first_letter::binary-size(1), _rest::binary>> = word, buckets ->
      Map.put(buckets, first_letter, [word | Map.get(buckets, first_letter, [])])
    end)
    |> Map.values()
    |> Enum.map(fn bucket_of_words ->
      Task.async(fn -> insert_many(bucket_of_words, nil) end)
    end)
    |> Enum.reduce(root, fn task, trie ->
      sub_trie = Task.await(task)
      %{trie | children: Map.merge(trie.children, sub_trie.children)}
    end)
  end

  def words_from_content(content) do
    content
    |> String.trim("\n")
    |> String.split("\n")
  end

  def check_string(trie, input) do
    input
    |> String.split(" ")
    |> Enum.reduce([], fn w, possible_misspellings ->
      word = format_word(w)

      case Spell.Trie.word_exists?(trie, word) do
        true -> possible_misspellings
        false -> [word | possible_misspellings]
      end
    end)
  end

  defp format_word(word) do
    word
    |> String.replace(~r/[\p{P}\p{S}]/, "")
    |> String.downcase()
  end
end
