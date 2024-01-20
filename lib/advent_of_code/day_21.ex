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
    #### I GAVE UP AND USED A SIMPLE QUADRATIC INTERPOLATION AS SEEN ON REDDIT. DONT LOOK AT THIS ####
    {full_garden, start} = args |> parse()
    {start_r, start_c} = start
    side = max(map(full_garden, fn {{r, _}, _} -> r end)) + 1

    garden =
      full_garden |> filter(fn {_, v} -> v == :rock end) |> map(&elem(&1, 0)) |> MapSet.new()

    1..10
    |> reduce(MapSet.new([start]), fn _, positions -> ione_step(positions, garden, side) end)
    |> count()

    n_rocks = count(garden)
    # Shifted plot
    shift_garden =
      MapSet.new(map(full_garden, fn {{r, c}, v} -> {{r - start_r, c - start_c}, v} end))
      |> reject(fn {_, v} -> v == :rock end)
      |> map(&elem(&1, 0))

    square = side * side
    semi_side = div(side - 1, 2)
    n_plot = square - n_rocks

    pieces =
      for {r, c} <- shift_garden do
        cond do
          abs(r) + abs(c) <= semi_side -> :heart
          r < 0 and c > 0 -> :top_right
          r < 0 and c < 0 -> :top_left
          r > 0 and c < 0 -> :bottom_left
          r > 0 and c > 0 -> :bottom_right
        end
      end
      |> Enum.frequencies()
      |> Map.put(:all, n_plot)
      |> then(fn map ->
        Map.put(
          map,
          :corners,
          map[:top_left] + map[:top_right] + map[:bottom_left] + map[:bottom_right]
        )
      end)

    IO.inspect({side, semi_side, square, n_plot, pieces})
    steps = 26_501_365
    bss = div(steps - semi_side, side)
    bssm = bss - 1
    # Coeur + horizontaux + verticaux
    full = (4 * div(bssm * (bssm - 1), 2) + 4 * bssm + 1) * pieces[:all]
    # Arêtes
    triangle = bss * pieces[:corners]
    cut = bssm * (3 * pieces[:all] + pieces[:heart])
    # Pics
    arrows = 4 * pieces[:heart] + 2 * pieces[:corners]
    full + cut + triangle + arrows
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
