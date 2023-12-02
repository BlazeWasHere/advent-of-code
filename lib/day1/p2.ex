defmodule Aoc.Day1.P2 do
  def main() do
    :code.priv_dir(:aoc)
    # Same input
    |> Path.join(["data/", "day1/", "p1.txt"])
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&handle_line(pre_handle_line(&1)))
    |> Enum.sum()
  end

  @pattern ~r/(one|two|three|four|five|six|seven|eight|nine)/
  def pre_handle_line(line) do
    @pattern
    |> Regex.scan(line)
    |> Enum.map(fn [match | _rest] -> word_to_num(match) end)
    |> Enum.with_index()
    |> Enum.reduce(line, fn {num, index}, acc ->
      String.replace(
        acc,
        @pattern,
        Integer.to_string(num),
        global: false,
        offset: index
      )
    end)
  end

  defp word_to_num(word) do
    case word do
      "one" -> 1
      "two" -> 2
      "three" -> 3
      "four" -> 4
      "five" -> 5
      "six" -> 6
      "seven" -> 7
      "eight" -> 8
      "nine" -> 9
      _ -> 0
    end
  end

  def handle_line(line) do
    ~r/\d/
    |> Regex.scan(line)
    # Capture first element
    |> Enum.map(fn [match | _rest] -> match end)
    |> then(&(List.first(&1) <> List.last(&1)))
    |> String.to_integer()
  end
end
