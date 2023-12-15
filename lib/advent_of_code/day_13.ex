defmodule AdventOfCode.Day13 do
  import Enum

  def to_num(?.), do: 0
  def to_num(?#), do: 1
  def parse_line(line), do: line |> to_charlist() |> map(&to_num/1)
  def parse_pattern(pattern), do: pattern |> String.split("\n", trim: true) |> map(&parse_line/1)
  def parse(args), do: args |> String.split("\n\n", trim: true) |> map(&parse_pattern/1)

  def bin2int(list), do: reduce(list, 0, fn x, acc -> acc * 2 + x end)

  # Reduce the pattern to 2 lists of integers: a list for the rows and a list for the column
  # Each list has one integer per line (resp column) which is an integer whose binary representation is the line
  def process_pattern(pattern) do
    # Convert the binary representation to one integer
    lines = map(pattern, &bin2int/1)
    # then transpose: loop on each column and convert to one integer
    rows = for i <- 0..(length(hd(pattern)) - 1), do: pattern |> map(&at(&1, i)) |> bin2int()
    [lines, rows]
  end

  # Cut the list in 2 and check if the reversed version of the first sublist equals the second part
  def pivot?(i, list) do
    {l, r} = split(list, i)
    cut_to = Kernel.min(length(r), length(l))
    slice(Enum.reverse(l), 0, cut_to) == slice(r, 0, cut_to)
  end

  # Detect the symmetries in a list of integers
  # Returns i : the symmetry is between the i-1 and the i integers
  def sym_list(list) do
    list
    |> with_index()
    # group the list by pairs of consecutive integers
    |> chunk_every(2, 1, :discard)
    # Potential symetry: the 2 integers are equal
    |> filter(fn [{x, _}, {y, _}] -> x == y end)
    |> map(fn [{_, _}, {_, i}] -> i end)
    # Check if the potential symmetry is a real symmetry
    |> filter(&pivot?(&1, list))
  end

  # Detect symmetries in a pattern and compute the score
  def score([lines, rows]) do
    v = lines |> sym_list() |> sum()
    h = rows |> sym_list() |> sum()
    h + 100 * v
  end

  def switch(1), do: 0
  def switch(0), do: 1

  # Switch one cell in a table
  def nudge(table, r, l) do
    for {row, cr} <- table |> with_index() do
      for {cell, cl} <- row |> with_index() do
        if r == cr and l == cl, do: switch(cell), else: cell
      end
    end
  end

  def value([{[{_, i}], []}]), do: i * 100
  def value([{[], [{_, i}]}]), do: i

  # reverse each cell in a table and check the symmetries for each resulting table
  def generate_nudge(table) do
    rows = length(table)
    lines = length(at(table, 0))
    [initial_hsym, initial_vsym] = table |> process_pattern() |> map(&sym_list/1)

    for r <- 0..(rows - 1), l <- 0..(lines - 1) do
      [current_hsym, current_vsym] = nudge(table, r, l) |> process_pattern() |> map(&sym_list/1)
      {current_hsym -- initial_hsym, current_vsym -- initial_vsym}
    end
    |> reject(fn {hs, vs} -> hs == [] and vs == [] end)
    |> uniq()
    |> value()
  end

  def part1(args), do: args |> parse() |> map(&process_pattern/1) |> map(&score/1) |> sum()

  def part2(args) do
    args |> parse() |> map(&generate_nudge/1) |> sum()
  end

  def test(_) do
    """
    #.##..##.
    ..#.##.#.
    ##......#
    ##......#
    ..#.##.#.
    ..##..##.
    #.#.##.#.

    #...##..#
    #....#..#
    ..##..###
    #####.##.
    #####.##.
    ..##..###
    #....#..#
    """
  end

  def test2(_) do
    """
    #.##..##.
    ..#.##.#.
    ##......#
    ##......#
    ..#.##.#.
    ..##..##.
    #.#.##.#.
    """
  end
end
