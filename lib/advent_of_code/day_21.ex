defmodule AdventOfCode.Day21 do
  import Enum

  def parse_line({line, row}) do
    for {char, col} <- with_index(to_charlist(line)) do
      case char do
        ?. -> {{row, col}, :plot}
        ?# -> {{row, col}, :rock}
        ?S -> {{row, col}, :start}
      end
    end
  end

  def parse(args) do
    garden =
      args
      |> String.split("\n", trim: true)
      |> with_index()
      |> map(&parse_line/1)
      |> List.flatten()
      |> into(%{})

    {start, _} = find(garden, fn {_, t} -> t == :start end)
    {Map.put(garden, start, :plot), start}
  end

  def reachable(garden, {r, c}) do
    reduce([{-1, 0}, {1, 0}, {0, -1}, {0, 1}], [], fn {dr, dc}, acc ->
      case garden[{r + dr, c + dc}] do
        nil -> acc
        :rock -> acc
        :plot -> [{r + dr, c + dc} | acc]
      end
    end)
  end

  def one_step(positions, garden) do
    positions
    |> reduce([], fn pos, acc -> prepend(reachable(garden, pos), acc) end)
    |> uniq()
  end

  def part1(args) do
    {garden, start} = args |> parse()
    reduce(1..64, [start], fn _, positions -> one_step(positions, garden) end) |> count()
  end

  def ireachable(garden, side, {r, c}) do
    reduce([{-1, 0}, {1, 0}, {0, -1}, {0, 1}], [], fn {dr, dc}, acc ->
      dest = {rem(r + dr, side), rem(c + dc, side)}

      case garden[dest] do
        nil -> acc
        :rock -> acc
        :plot -> [{r + dr, c + dc} | acc]
      end
    end)
  end

  def prepend([], b), do: b
  def prepend([a | r], b), do: prepend(r, [a | b])

  def ione_step(positions, garden, side) do
    positions
    |> reduce([], fn pos, acc -> prepend(ireachable(garden, side, pos), acc) end)
    |> uniq()
  end

  def part2(args) do
    {garden, start} = args |> test() |> parse()
    side = (garden |> Map.keys() |> map(fn {r, _} -> r end) |> max()) + 1
    reduce(1..10, [start], fn _, positions -> ione_step(positions, garden, side) end) |> count()
  end

  def test(_) do
    """
    ...........
    .....###.#.
    .###.##..#.
    ..#.#...#..
    ....#.#....
    .##..S####.
    .##..#...#.
    .......##..
    .##.#.####.
    .##..##.##.
    ...........
    """
  end
end
