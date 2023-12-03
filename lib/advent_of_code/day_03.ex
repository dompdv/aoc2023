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

  def parse_sudoku(input) do
    input
    |> String.split("\n", trim: true)
    |> with_index()
    |> map(fn {line, row} ->
      line
      |> String.trim()
      |> to_charlist()
      |> with_index()
      |> map(fn {char, col} -> {{row, col}, char - ?0} end)
    end)
    |> List.flatten()
    |> Enum.filter(fn {_, char} -> char != ?. - ?0 end)
    |> Enum.into(%{})
  end

  @all_numbers for(i <- 1..9, do: i) |> MapSet.new()

  def possible(array, {row, col}) do
    if array[{row, col}] != nil do
      MapSet.new([array[{row, col}]])
    else
      row_s = div(row, 3) * 3
      col_s = div(col, 3) * 3

      @all_numbers
      |> MapSet.difference(MapSet.new(for c <- 0..8, do: array[{row, c}]))
      |> MapSet.difference(MapSet.new(for r <- 0..8, do: array[{r, col}]))
      |> MapSet.difference(
        MapSet.new(for r <- row_s..(row_s + 2), c <- col_s..(col_s + 2), do: array[{r, c}])
      )
    end
  end

  def solve(array, {9, 0}), do: array

  def solve(array, {row, col}) do
    p = possible(array, {row, col})

    if p == MapSet.new() do
      nil
    else
      next_col = rem(col + 1, 9)
      next_row = if next_col == 0, do: row + 1, else: row

      Enum.reduce(p, nil, fn n, sols ->
        case solve(Map.put(array, {row, col}, n), {next_row, next_col}) do
          nil -> sols
          sol -> sol
        end
      end)
    end
  end

  def display_sudoku(array) do
    for row <- 0..8 do
      if rem(row, 3) == 0 do
        IO.puts("+-------+-------+-------+")
      end

      for col <- 0..8 do
        cell = array[{row, col}]

        if rem(col, 3) == 0 do
          IO.write("| ")
        end

        if cell == nil do
          IO.write(". ")
        else
          IO.write("#{cell} ")
        end
      end

      IO.puts("|")
    end

    IO.puts("+-------+-------+-------+")
  end

  def sudoku() do
    start =
      """
      .46.5..82
      .....3..7
      .....61..
      .9......8
      ...7.8...
      1.8....9.
      ..56.....
      4..8.....
      38..1.56.
      """
      |> parse_sudoku()

    solve(start, {0, 0})
    |> display_sudoku()
  end
end
