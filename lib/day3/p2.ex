defmodule Aoc.Day3.P2 do
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
        symbols: search_for(~r/(\*)/, line)
      }
    }
  end

  def search_for(regex, line) do
    regex
    |> Regex.scan(line, return: :index, capture: :all_but_first)
    |> List.flatten()
  end

  def handle_lines(mats, lines) do
    Enum.flat_map(mats, fn {i, data} ->
      Enum.map(data.symbols, fn pos ->
        adj = get_adjacents(i, pos, mats)

        cond do
          length(adj) == 2 ->
            Enum.reduce(adj, 1, fn {index, loc}, acc ->
              Enum.at(lines, index)
              |> String.slice(elem(loc, 0), elem(loc, 1))
              |> String.to_integer()
              |> Kernel.*(acc)
            end)

          true ->
            0
        end
      end)
    end)
  end

  def get_adjacents(index, pos, mats) do
    to_the_right(index, pos, mats) ++
      to_the_left(index, pos, mats) ++
      to_the_bottom(index, pos, mats) ++ to_the_top(index, pos, mats)
  end

  def to_the_right(index, {start_pos, end_pos}, mats)
      when start_pos + end_pos < @max_line_len do
    # Search for:
    # . . . . TGT x . . .
    mats[index].ints
    |> Enum.filter(&Enum.member?(to_range(&1), start_pos + end_pos))
    |> Enum.map(&{index, &1})
  end

  def to_the_right(_index, {_start_pos, _end_pos}, _mats), do: []

  def to_the_left(index, {start_pos, _end_pos}, mats) when start_pos > 1 do
    # Search for:
    # . . . x TGT . . . .

    mats[index].ints
    |> Enum.filter(&Enum.member?(to_range(&1), start_pos - 1))
    |> Enum.map(&{index, &1})
  end

  def to_the_left(_index, {_start_pos, _end_pos}, _mats), do: []

  def to_the_top(index, {start_pos, end_pos}, mats) when index > 0 do
    # Search for:
    # . . . x x x x . . .
    # . . . . TGT . . . .
    target = constrainted_range(start_pos - 1, start_pos + end_pos)

    mats[index - 1].ints
    |> Enum.filter(&overlap?(target, to_range(&1)))
    |> Enum.map(&{index - 1, &1})
  end

  def to_the_top(index, {_start_pos, _end_pos}, _mats) when index == 0, do: []

  def to_the_bottom(index, {start_pos, end_pos}, mats) do
    # Search for:
    # . . . . TGT . . . .
    # . . . x x x x . . .
    target = constrainted_range(start_pos - 1, start_pos + end_pos)

    case Map.get(mats, index + 1) do
      mat when not is_nil(mat) ->
        mat.ints
        |> Enum.filter(&overlap?(target, to_range(&1)))
        |> Enum.map(&{index + 1, &1})

      _ ->
        []
    end
  end

  def constrainted_range(first, last),
    do: Range.new(Enum.max([first, 0]), Enum.min([last, @max_line_len]))

  def overlap?(l1, l2), do: not MapSet.disjoint?(MapSet.new(l1), MapSet.new(l2))

  def to_range({from, to}), do: from..(from + to - 1)
end
