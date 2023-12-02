defmodule Aoc.Day1.P1 do
  def main() do
    :code.priv_dir(:aoc)
    |> Path.join(["data/", "day1/", "p1.txt"])
    |> File.read!()
    |> String.split("\n", trim: true)
    |> Enum.map(&handle_line/1)
    |> Enum.sum()
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
