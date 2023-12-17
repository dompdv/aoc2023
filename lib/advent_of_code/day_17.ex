defmodule AdventOfCode.Day17 do
  import Enum

  @directions %{north: {-1, 0}, south: {1, 0}, east: {0, 1}, west: {0, -1}}
  @last_three_directions [
    [:north, :north, :north],
    [:south, :south, :south],
    [:east, :east, :east],
    [:west, :west, :west]
  ]
  def parse_line(line, r) do
    line
    |> to_charlist()
    |> with_index()
    |> map(fn {char, c} -> {{r, c}, char - ?0} end)
  end

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> with_index()
    |> map(fn {line, r} -> parse_line(line, r) end)
    |> List.flatten()
    |> Map.new()
  end

  def dj(grid) do
    nil
  end

  def part1(args) do
    grid = args |> test() |> parse()
    dj(grid)
  end

  def part2(_args) do
    :ok
  end

  def test(_) do
    """
    2413432311323
    3215453535623
    3255245654254
    3446585845452
    4546657867536
    1438598798454
    4457876987766
    3637877979653
    4654967986887
    4564679986453
    1224686865563
    2546548887735
    4322674655533
    """
  end
end
