defmodule AdventOfCode.Day14 do
  import Enum

  def to_num(?.), do: 0
  def to_num(?#), do: 1
  def to_num(?O), do: 2

  def parse_line(line), do: line |> to_charlist() |> map(&to_num/1)

  def parse(args) do
    rockroll =
      for {row, r} <- args |> String.split("\n", trim: true) |> with_index(),
          {cell, c} <- row |> to_charlist() |> with_index() do
        case cell do
          ?. -> nil
          ?# -> {{r, c}, :rock}
          ?O -> {{r, c}, :roll}
        end
      end

    {max(for {{r, _}, _} <- rockroll, do: r),
     rockroll
     |> reject(&(&1 == nil))
     |> with_index()
     |> map(fn {{pos, type}, i} -> {i, {pos, type}} end)
     |> Map.new()}
  end

  def north_blocked_by(rockroll, {row, col}) do
    case filter(rockroll, fn {_, {{r, c}, _}} -> r < row and c == col end) do
      [] -> nil
      l -> max_by(l, fn {_, {{r, _}, _}} -> r end)
    end
  end

  def south_blocked_by(rockroll, {row, col}) do
    case filter(rockroll, fn {_, {{r, c}, _}} -> r > row and c == col end) do
      [] -> nil
      l -> min_by(l, fn {_, {{r, _}, _}} -> r end)
    end
  end

  def west_blocked_by(rockroll, {row, col}) do
    case filter(rockroll, fn {_, {{r, c}, _}} -> c < col and r == row end) do
      [] -> nil
      l -> max_by(l, fn {_, {{_, c}, _}} -> c end)
    end
  end

  def east_blocked_by(rockroll, {row, col}) do
    case filter(rockroll, fn {_, {{r, c}, _}} -> c > col and r == row end) do
      [] -> nil
      l -> min_by(l, fn {_, {{_, c}, _}} -> c end)
    end
  end

  def find_blockers(rockroll) do
    for {i, {pos, type}} = r <- rockroll do
      if type == :rock do
        r
      else
        blockers = %{
          :north => north_blocked_by(rockroll, pos),
          :south => south_blocked_by(rockroll, pos),
          :east => east_blocked_by(rockroll, pos),
          :west => west_blocked_by(rockroll, pos)
        }

        {i, {pos, type, blockers}}
      end
    end
    |> Map.new()
  end

  def build_dependent_list(rockroll, s, acc, direction) do
    case find(rockroll, fn
           {_, {_, :roll, %{^direction => {^s, _}}}} -> true
           _ -> false
         end) do
      nil ->
        reverse(acc)

      {i, _} ->
        build_dependent_list(rockroll, i, [i | acc], direction)
    end
  end

  def to_graph(rockroll, direction) do
    # Find the first roll in the direction
    filter(rockroll, fn
      {_, {_, :roll, %{^direction => nil}}} -> true
      {_, {_, :roll, %{^direction => {_, {_, :rock}}}}} -> true
      _ -> false
    end)
    |> map(&elem(&1, 0))
    |> map(fn s -> build_dependent_list(rockroll, s, [s], direction) end)
  end

  def move_from(l, rockroll, direction, computed) do

  end
  end
  def part1(args) do
    {_side, rockroll} = args |> test() |> parse()
    blockers = rockroll |> find_blockers()

    computation_graph =
      for(dir <- [:north, :south, :east, :west], do: {dir, to_graph(blockers, dir)}) |> Map.new()

    direction = :north
    reduce(computation_graph, Map.new(), fn l, acc -> move_from(l, blockers, direction, acc) end)
  end

  def part2(_args) do
  end

  def test(_) do
    """
    O....#....
    O.OO#....#
    .....##...
    OO.#O....O
    .O.....O#.
    O.#..O.#.#
    ..O..#O..O
    .......O..
    #....###..
    #OO..#....
    """
  end
end
