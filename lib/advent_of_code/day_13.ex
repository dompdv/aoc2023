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

  def pivot?({i, j}, list) do
    {l, r} = split(list, i + 1) |> IO.inspect()
    cut_to = Kernel.min(length(r), length(l))
    l = Enum.reverse(l)
    IO.inspect({Enum.slice(l, 0, cut_to), Enum.slice(r, 0, cut_to)})
    Enum.slice(l, 0, cut_to) == Enum.slice(r, 0, cut_to)
  end

  def identitfy_pivots(list) do
    list
    |> with_index()
    |> chunk_every(2, 1, :discard)
    |> filter(fn [{x, _}, {y, _}] -> x == y end)
    |> map(fn [{_, i}, {_, j}] -> {i, j} end)
    |> filter(&pivot?(&1, list))
  end

  def sym_list(list) do
    identitfy_pivots(list)
  end

  def detect_symmetry({lines, rows}) do
    case {sym_list(lines), sym_list(rows)} do
      {[], []} -> :none
      {[{_, r}], []} -> 100 * r
      {[], [{_, l}]} -> l
      _ -> :both
    end
  end

  def parse(args), do: args |> String.split("\n\n", trim: true) |> map(&parse_pattern/1)

  def part1(args) do
    args |> parse() |> map(&process_pattern/1) |> map(&detect_symmetry/1) |> sum()
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
