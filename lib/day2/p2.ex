defmodule Aoc.Day2.P2 do
  def main() do
    :code.priv_dir(:aoc)
    |> Path.join(["data/", "day2/", "p1.txt"])
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&handle_line/1)
    |> Enum.sum()
  end

  def handle_line(line) do
    ~r/Game (\d+): (.*)/
    |> Regex.scan(line, capture: :all_but_first)
    |> then(fn [[_id, sets]] -> String.split(sets, "; ") end)
    |> check_if_possible()
    |> then(&(&1["red"] * &1["green"] * &1["blue"]))
  end

  def check_if_possible(sets) do
    sets
    |> Enum.reduce(%{"red" => 0, "green" => 0, "blue" => 0}, fn x, acc ->
      Enum.reduce(parse_full_set(x), acc, fn {num, color}, acc ->
        cond do
          acc[color] < num -> Map.put(acc, color, num)
          true -> acc
        end
      end)
    end)
  end

  def parse_full_set(set), do: Enum.map(String.split(set, ", "), &parse_set/1)

  def parse_set(<<num::binary-size(1), " ", color::binary>>),
    do: {String.to_integer(num), color}

  def parse_set(<<num::binary-size(2), " ", color::binary>>),
    do: {String.to_integer(num), color}
end
