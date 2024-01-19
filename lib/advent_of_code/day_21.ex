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

  def reachable(garden, {r, c}, start_acc) do
    reduce([{-1, 0}, {1, 0}, {0, -1}, {0, 1}], start_acc, fn {dr, dc}, acc ->
      case garden[{r + dr, c + dc}] do
        nil -> acc
        :rock -> acc
        :plot -> MapSet.put(acc, {r + dr, c + dc})
      end
    end)
  end

  def one_step(positions, garden) do
    reduce(positions, MapSet.new(), fn pos, acc -> reachable(garden, pos, acc) end)
  end

  def part1(args) do
    {garden, start} = args |> parse()
    IO.inspect(count(garden))
    IO.inspect(count(garden, fn {_, v} -> v == :plot end))

    reduce(1..64, MapSet.new([start]), fn _, positions -> one_step(positions, garden) end)
    |> count()

    # 202300
  end

  def remp(a, b) do
    r = rem(a, b)
    if r < 0, do: b + r, else: r
  end

  def ireachable(garden, side, {r, c}, start_acc) do
    reduce([{-1, 0}, {1, 0}, {0, -1}, {0, 1}], start_acc, fn {dr, dc}, acc ->
      dest = {remp(r + dr, side), remp(c + dc, side)}
      if MapSet.member?(garden, dest), do: acc, else: MapSet.put(acc, {r + dr, c + dc})
    end)
  end

  def ione_step(positions, garden, side) do
    reduce(positions, MapSet.new(), fn pos, acc -> ireachable(garden, side, pos, acc) end)
  end

  def part2(args) do
    {garden, start} = args |> test() |> parse()
    side = max(map(garden, fn {{r, _}, _} -> r end)) + 1
    garden = garden |> filter(fn {_, v} -> v == :rock end) |> map(&elem(&1, 0)) |> MapSet.new()

    IO.inspect({side, side * side, count(garden), side * side - count(garden)})

    reduce(1..100, MapSet.new([start]), fn _, positions -> ione_step(positions, garden, side) end)
    |> count()
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
