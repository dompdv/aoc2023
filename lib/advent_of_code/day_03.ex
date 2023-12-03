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

        {row, zip(numbers, columns)}
      end)
      |> filter(fn {_, l} -> l != [] end)
      |> map(fn {row, l} -> for z <- l, do: {row, z} end)
      |> List.flatten()

    {array, numbers}
  end

  def identify_adjacents(array, test) do
    array
    |> reduce(MapSet.new(), fn {{row, col}, _}, acc ->
      char = array[{row, col}]

      if test.(char) do
        acc
      else
        cells = for r <- (row - 1)..(row + 1), c <- (col - 1)..(col + 1), do: {r, c}
        MapSet.union(acc, MapSet.new(cells))
      end
    end)
  end

  def adjacent_number?(row, {start, len}, adjacents) do
    Enum.any?(start..(start + len - 1), fn col -> MapSet.member?(adjacents, {row, col}) end)
  end

  def part1(args) do
    {array, numbers} = args |> parse()
    adjacents = identify_adjacents(array, fn char -> char in ?0..?9 end)

    numbers
    |> filter(fn {row, {n, interval}} -> adjacent_number?(row, interval, adjacents) end)
    |> Enum.map(fn {_, {n, _}} -> n end)
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

    {array, numbers} = args |> parse()
    stars = filter(array, fn {_, char} -> char == ?* end)
  end
end
