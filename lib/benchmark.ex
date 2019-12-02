defmodule Benchmark do
  def measure(function, opts \\ []) do
    defaults = [repeat: 1, time_format: :seconds]
    opts = Keyword.merge(defaults, opts)

    final_result =
      measure(function, opts[:repeat], opts[:repeat], 0, opts[:time_format]) /
        opts[:repeat]

    IO.puts("Time\t... #{final_result} #{opts[:time_format]}")
  end

  defp measure(_function, 0 = _call_count, _total_calls, acc, _time_format), do: acc

  defp measure(function, call_count, total_calls, acc, time_format) do
    result =
      function
      |> :timer.tc()
      |> elem(0)
      |> Kernel./(time_conversion(time_format))

    if total_calls > 1 do
      IO.puts('⌚️ ##{abs(call_count - total_calls) + 1}\t... #{result} #{time_format}')
    end

    measure(function, call_count - 1, total_calls, acc + result, time_format)
  end

  defp time_conversion(:microseconds), do: 1
  defp time_conversion(:milliseconds), do: 1_000
  defp time_conversion(:seconds), do: 1_000_000
end
