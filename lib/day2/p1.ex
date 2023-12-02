defmodule Aoc.Day2.P1 do
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
    |> then(fn [[id, sets]] -> {String.to_integer(id), String.split(sets, "; ")} end)
    |> check_if_possible()
  end

  def check_if_possible({id, sets}) do
    sets
    |> Enum.map(&Enum.all?(parse_full_set(&1), fn x -> is_under_limit?(x) end))
    |> Enum.all?()
    |> decide(id)
  end

  def decide(true, id), do: id
  def decide(false, _), do: 0

  def is_under_limit?({num, color}) when color in ["red", "green", "blue"] do
    case color do
      "red" -> num <= 12
      "green" -> num <= 13
      "blue" -> num <= 14
    end
  end

  def parse_full_set(set), do: Enum.map(String.split(set, ", "), &parse_set/1)

  def parse_set(<<num::binary-size(1), " ", color::binary>>),
    do: {String.to_integer(num), color}

  def parse_set(<<num::binary-size(2), " ", color::binary>>),
    do: {String.to_integer(num), color}
end
