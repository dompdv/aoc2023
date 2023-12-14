defmodule AdventOfCode.Day13 do
  import Enum

  def parse_pattern(pattern) do
    pattern
    |> String.split("\n", trim: true)
    |> map(fn line ->
      line
      |> to_charlist()
      |> map(fn
        ?. -> 0
        ?# -> 1
      end)
    end)
  end

  def bin2int(list), do: reduce(list, 0, fn x, acc -> acc * 2 + x end)

  def process_pattern(pattern) do
    lines = map(pattern, &bin2int/1)

    rows =
      for i <- 0..(length(hd(pattern)) - 1) do
        pattern |> map(&at(&1, i)) |> bin2int()
      end

    {lines, rows}
  end

  def sym_list(list) do
    # |> map(fn [a, b] -> a == b end)
    list
    |> with_index()
    |> chunk_every(2, 1, :discard)
    |> filter(fn [{x, _}, {y, _}] -> x == y end)
    |> map(fn [{_, i}, {_, j}] -> {i, j} end)
  end

  def detect_symmetry({lines, rows}) do
    sym_list(lines)
    sym_list(rows)
  end

  def parse(args), do: args |> String.split("\n\n", trim: true) |> map(&parse_pattern/1)

  def part1(args) do
    args
    |> test()
    |> parse()
    |> map(&process_pattern/1)
    |> IO.inspect()
    |> map(&detect_symmetry/1)
  end

  def part2(_args) do
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
end
