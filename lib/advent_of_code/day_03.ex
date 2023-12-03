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

    # %{{row,col} => char}}
    array =
      lines
      |> with_index()
      |> map(&parse_line/1)
      |> List.flatten()

    # List of [{row, [{number, {start, len}}]}
    numbers =
      lines
      |> with_index()
      |> map(fn {text, row} ->
        numbers = Regex.scan(~r/\d+/, text) |> List.flatten() |> map(&String.to_integer/1)
        columns = Regex.scan(~r/\d+/, text, return: :index) |> List.flatten()

        {row, zip(numbers, columns)}
      end)
      # remove lines without numbers
      |> filter(fn {_, l} -> l != [] end)
      # flatten list of lists
      |> map(fn {row, l} -> for z <- l, do: {row, z} end)
      |> List.flatten()

    {array, numbers}
  end

  # Create a set of all the adjacent cells of a symbol
  def identify_adjacents(array) do
    array
    # Keep symbols
    |> filter(fn {_, char} -> char not in ?0..?9 end)
    # Build a set of all the adjacent cells
    |> reduce(MapSet.new(), fn {{row, col}, _}, acc ->
      cells = for r <- (row - 1)..(row + 1), c <- (col - 1)..(col + 1), do: {r, c}
      MapSet.union(acc, MapSet.new(cells))
    end)
  end

  def adjacent_number?(row, {start, len}, adjacents) do
    Enum.any?(start..(start + len - 1), fn col -> MapSet.member?(adjacents, {row, col}) end)
  end

  def part1(args) do
    {array, numbers} = args |> parse()
    adjacents = identify_adjacents(array)

    numbers
    # Keep only the numbers with an adjacent symbol
    |> filter(fn {row, {_n, interval}} -> adjacent_number?(row, interval, adjacents) end)
    # Keep only the numbers
    |> Enum.map(fn {_, {n, _}} -> n end)
    |> Enum.sum()
  end

  # Find the numbers adjacent to the given position
  def find_adjacent_numbers({r, c}, numbers) do
    numbers
    |> filter(fn {row, {_n, {start, len}}} ->
      r in (row - 1)..(row + 1) and c in (start - 1)..(start + len)
    end)
    # Keep only the numbers
    |> Enum.map(fn {_, {n, _}} -> n end)
  end

  def part2(args) do
    {array, numbers} = parse(args)

    array
    # Keep only the cells with a star
    |> filter(fn {_, char} -> char == ?* end)
    # Find adjacent numbers
    |> map(fn {pos, _} -> {pos, find_adjacent_numbers(pos, numbers)} end)
    # Keep only the cells with two adjacent numbers
    |> filter(fn {_, l} -> length(l) == 2 end)
    # Multiply the two numbers
    |> map(fn {_, l} -> product(l) end)
    |> sum()
  end
end
