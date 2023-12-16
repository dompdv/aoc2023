defmodule AdventOfCode.Day14 do
  import Enum

  def to_num(?.), do: 0
  def to_num(?#), do: 1
  def to_num(?O), do: 2

  def parse_line(line), do: line |> to_charlist() |> map(&to_num/1)

  def parse(args) do
    rows = args |> String.split("\n", trim: true)
    side = length(rows)

    {rocks, rolls} =
      for {row, r} <- rows |> with_index(),
          {cell, c} <- row |> to_charlist() |> with_index() do
        case cell do
          ?. -> nil
          ?# -> {{r, c}, :rock}
          ?O -> {{r, c}, :roll}
        end
      end
      |> reject(&(&1 == nil))
      |> split_with(&(elem(&1, 1) == :rock))
      |> then(fn {rocks, rolls} ->
        {rocks |> map(&elem(&1, 0)), rolls |> map(&elem(&1, 0))}
      end)

    {side, rocks, rolls}
  end

  def map_by_rc(pos_list) do
    reduce(
      pos_list,
      {%{}, %{}},
      fn {r, c}, {by_r, by_c} ->
        {Map.update(by_r, r, [c], fn l -> [c | l] end),
         Map.update(by_c, c, [r], fn l -> [r | l] end)}
      end
    )
  end

  def find_up(_x, nil), do: 0

  def find_up(x, l) do
    case filter(l, &(&1 < x)) do
      [] -> 0
      m -> max(m) + 1
    end
  end

  def move_north(side, {rocks_by_r, rocks_by_c}, {rolls_by_r, _rolls_by_c}) do
    reduce(
      0..(side - 1),
      %{},
      fn r, moved_rolls_by_c_1 ->
        # IO.inspect({r, rolls_by_r[r], moved_rolls_by_c_1}, label: "r")
        rolls_in_this_row = Map.get(rolls_by_r, r, [])

        reduce(
          rolls_in_this_row,
          moved_rolls_by_c_1,
          fn c, moved_rolls_by_c_2 ->
            #            if c == 2, do: IO.inspect({r, c, moved_rolls_by_c_2, rocks_by_c[c]}, label: "c")

            blocking_roll =
              if Map.has_key?(moved_rolls_by_c_2, c), do: hd(moved_rolls_by_c_2[c]) + 1, else: 0

            blocking_rock = find_up(r, rocks_by_c[c])

            new_row = Kernel.max(blocking_rock, blocking_roll)
            Map.update(moved_rolls_by_c_2, c, [new_row], fn l -> [new_row | l] end)
          end
        )
      end
    )
  end

  def part1(args) do
    {side, rocks, rolls} = args |> parse()

    for {_r, l} <- move_north(side, map_by_rc(rocks), map_by_rc(rolls)) do
      sum(for r <- l, do: side - r)
    end
    |> sum()
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
