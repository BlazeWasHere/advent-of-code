defmodule Aoc.Day3.P1 do
  @max_line_len 140

  def main() do
    lines =
      :code.priv_dir(:aoc)
      |> Path.join(["data/", "day3/", "p1.txt"])
      |> File.read!()
      |> String.split("\n", trim: true)

    lines
    |> Enum.with_index()
    |> Enum.map(&pre_handle_line/1)
    |> Enum.reduce(%{}, &Enum.into/2)
    |> handle_lines(lines)
    |> Enum.sum()
  end

  def pre_handle_line({line, index}) do
    %{
      index => %{
        ints: search_for(~r/(\d+)/, line),
        symbols: search_for(~r/(\*|#|\+|\$|%|@|&|-|=|\/)/, line)
      }
    }
  end

  def search_for(regex, line) do
    regex
    |> Regex.scan(line, return: :index, capture: :all_but_first)
    |> List.flatten()
  end

  def handle_lines(mats, lines) do
    Enum.flat_map(
      mats,
      fn {i, data} ->
        Enum.map(data.ints, fn pos ->
          case has_adjacent?(i, pos, mats) do
            true ->
              Enum.at(lines, i)
              |> String.slice(elem(pos, 0), elem(pos, 1))
              |> String.to_integer()

            false ->
              0
          end
        end)
      end
    )
  end

  def has_adjacent?(index, pos, mats) do
    to_the_right?(index, pos, mats) or to_the_left?(index, pos, mats) or
      to_the_bottom?(index, pos, mats) or to_the_top?(index, pos, mats)
  end

  def to_the_right?(index, {start_pos, end_pos}, mats)
      when start_pos + end_pos < @max_line_len do
    # Search for:
    # . . . . TGT x . . .

    Enum.any?(mats[index].symbols, &(elem(&1, 0) == start_pos + end_pos))
  end

  def to_the_right?(_index, {_start_pos, _end_pos}, _mats), do: false

  def to_the_left?(index, {start_pos, _end_pos}, mats) when start_pos > 1 do
    # Search for:
    # . . . x TGT . . . .
    Enum.any?(mats[index].symbols, &(elem(&1, 0) == start_pos - 1))
  end

  def to_the_left?(_index, {_start_pos, _end_pos}, _mats), do: false

  def to_the_top?(index, {start_pos, end_pos}, mats) when index > 0 do
    # Search for:
    # . . . x x x x . . .
    # . . . . TGT . . . .
    target = constrainted_range(start_pos - 1, start_pos + end_pos)
    Enum.any?(mats[index - 1].symbols, &Enum.member?(target, elem(&1, 0)))
  end

  def to_the_top?(index, {_start_pos, _end_pos}, _mats) when index == 0, do: false

  def to_the_bottom?(index, {start_pos, end_pos}, mats) do
    # Search for:
    # . . . . TGT . . . .
    # . . . x x x x . . .
    target = constrainted_range(start_pos - 1, start_pos + end_pos)

    case Map.get(mats, index + 1) do
      mat when not is_nil(mat) ->
        Enum.any?(mat.symbols, &Enum.member?(target, elem(&1, 0)))

      _ ->
        false
    end
  end

  def constrainted_range(first, last),
    do: Range.new(Enum.max([first, 0]), Enum.min([last, @max_line_len]))
end
