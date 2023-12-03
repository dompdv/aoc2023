defmodule AdventOfCode.Day03 do
  import Enum

  def parse_line({line, row_number}) do
    line
    |> to_charlist()
    |> with_index()
    |> filter(fn {char, _} -> char != ?. end)
    |> map(fn {c, col_number} -> {{row_number, col_number}, c} end)
  end

  def parse(input) do
    lines = String.split(input, "\n", trim: true)
    rows = lines |> length()
    cols = lines |> hd() |> String.length()

    array =
      lines
      |> with_index()
      |> map(&parse_line/1)
      |> List.flatten()
      |> Map.new()

    numbers =
      lines
      |> with_index()
      |> map(fn {text, row} ->
        numbers = Regex.scan(~r/\d+/, text) |> List.flatten() |> map(&String.to_integer/1)
        columns = Regex.scan(~r/\d+/, text, return: :index) |> List.flatten()

        {row, numbers, columns}
      end)
      |> filter(fn {_, numbers, _} -> numbers != [] end)
      |> map(fn {row, numbers, columns} -> {row, zip(numbers, columns)} end)
      |> Map.new()

    {rows, cols, array, numbers, identify_adjacents(array)}
  end

  def identify_adjacents(array) do
    array
    |> reduce(MapSet.new(), fn {{row, col}, _}, acc ->
      char = array[{row, col}]

      if char in ?0..?9 do
        acc
      else
        acc
        |> MapSet.put({row - 1, col - 1})
        |> MapSet.put({row - 1, col})
        |> MapSet.put({row - 1, col + 1})
        |> MapSet.put({row, col - 1})
        |> MapSet.put({row, col + 1})
        |> MapSet.put({row + 1, col - 1})
        |> MapSet.put({row + 1, col})
        |> MapSet.put({row + 1, col + 1})
      end
    end)
  end

  def adjacent_number?(row, {start, len}, adjacents) do
    Enum.any?(start..(start + len - 1), fn col -> MapSet.member?(adjacents, {row, col}) end)
  end

  def part1(args) do
    {_rows, _cols, array, numbers, adjacents} = args |> parse()

    for {row, ns} <- numbers do
      filter(ns, fn {n, interval} -> adjacent_number?(row, interval, adjacents) end)
    end
    |> List.flatten()
    |> Enum.map(fn {n, _} -> n end)
    |> Enum.sum()
  end

  def part2(args) do
    args = """
    467..114..
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.
    ..592.....
    ......755.
    ...$.*....
    .664.598..
    """

    args
    :ok
  end
end
