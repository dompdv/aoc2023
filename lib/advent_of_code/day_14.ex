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
          ?# -> {:rock, {r, c}}
          ?O -> {:roll, {r, c}}
        end
      end

    side = max(for {_, {r, _}} <- rockroll, do: r)

    {rocks, rolls} =
      reduce(
        rockroll,
        {MapSet.new(), MapSet.new()},
        fn
          nil, acc -> acc
          {:rock, pos}, {kacc, lacc} -> {MapSet.put(kacc, pos), lacc}
          {:roll, pos}, {kacc, lacc} -> {kacc, MapSet.put(lacc, pos)}
        end
      )

    {rocks, rolls, side}
  end

  def part1(args) do
    args |> parse()
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
