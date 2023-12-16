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

  # Map like %{row => [columns of the rolls in this row], column => [rows of the rolls in this column]}
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

  def find_down(side, _x, nil), do: side - 1

  def find_down(side, x, l) do
    case filter(l, &(&1 > x)) do
      [] -> side - 1
      m -> min(m) - 1
    end
  end

  def move_north(rolls, side, {_rocks_by_r, rocks_by_c}) do
    # Create a map of rolls by row and column
    {rolls_by_r, _rolls_by_c} = map_by_rc(rolls)

    new_rolls_by_c =
      reduce(
        # Loop over the rows from north to south
        0..(side - 1),
        # Map like %{column, [updated rows of the rolls for this column]}
        %{},
        fn r, moved_by_c ->
          # Loop over the rolls in this row, if any
          Map.get(rolls_by_r, r, [])
          |> reduce(
            # updating  the map of rolls by column
            moved_by_c,
            fn c, inner_by_c ->
              # Is there a roll in this column in the direction we're moving? If yes, the roll is blocked by it, otherwise it's blocked by the edge of the board
              blocking_roll =
                if Map.has_key?(inner_by_c, c),
                  do: hd(inner_by_c[c]) + 1,
                  else: 0

              # Is there a blocking rock in this column? If yes, the roll is blocked by it, otherwise it's blocked by the edge of the board
              blocking_rock = find_up(r, rocks_by_c[c])
              # The new row of the roll is the maximum of the blocking roll and the blocking rock
              new_row = Kernel.max(blocking_rock, blocking_roll)
              # Update the map of rolls by column
              Map.update(inner_by_c, c, [new_row], fn l -> [new_row | l] end)
            end
          )
        end
      )

    # recreate the list of rolls by row and column
    for {c, l} <- new_rolls_by_c, r <- l, do: {r, c}
  end

  def move_south(rolls, side, {_rocks_by_r, rocks_by_c}) do
    {rolls_by_r, _rolls_by_c} = map_by_rc(rolls)

    new_rolls_by_c =
      reduce(
        (side - 1)..0,
        %{},
        fn r, moved_by_c ->
          Map.get(rolls_by_r, r, [])
          |> reduce(
            moved_by_c,
            fn c, inner_by_c ->
              blocking_roll =
                if Map.has_key?(inner_by_c, c),
                  do: hd(inner_by_c[c]) - 1,
                  else: side - 1

              blocking_rock = find_down(side, r, rocks_by_c[c])

              new_row = Kernel.min(blocking_rock, blocking_roll)
              Map.update(inner_by_c, c, [new_row], fn l -> [new_row | l] end)
            end
          )
        end
      )

    for {c, l} <- new_rolls_by_c, r <- l, do: {r, c}
  end

  def move_west(rolls, side, {rocks_by_r, _rocks_by_c}) do
    # Create a map of rolls by row and column
    {_rolls_by_r, rolls_by_c} = map_by_rc(rolls)

    new_rolls_by_r =
      reduce(
        # Loop over the rows from west to east
        0..(side - 1),
        # Map like %{rows, [updated rows of the rolls for this row]}
        %{},
        fn c, moved_by_r ->
          # Loop over the rolls in this row, if any
          Map.get(rolls_by_c, c, [])
          |> reduce(
            # updating  the map of rolls by column
            moved_by_r,
            fn r, inner_by_r ->
              # Is there a roll in this column in the direction we're moving? If yes, the roll is blocked by it, otherwise it's blocked by the edge of the board
              blocking_roll =
                if Map.has_key?(inner_by_r, r),
                  do: hd(inner_by_r[r]) + 1,
                  else: 0

              # Is there a blocking rock in this column? If yes, the roll is blocked by it, otherwise it's blocked by the edge of the board
              blocking_rock = find_up(c, rocks_by_r[r])
              # The new row of the roll is the maximum of the blocking roll and the blocking rock
              new_c = Kernel.max(blocking_rock, blocking_roll)
              # Update the map of rolls by column
              Map.update(inner_by_r, r, [new_c], fn l -> [new_c | l] end)
            end
          )
        end
      )

    # recreate the list of rolls by row and column
    for {r, l} <- new_rolls_by_r, c <- l, do: {r, c}
  end

  def move_east(rolls, side, {rocks_by_r, _rocks_by_c}) do
    {_rolls_by_r, rolls_by_c} = map_by_rc(rolls)

    new_rolls_by_r =
      reduce(
        (side - 1)..0,
        %{},
        fn c, moved_by_r ->
          Map.get(rolls_by_c, c, [])
          |> reduce(
            moved_by_r,
            fn r, inner_by_r ->
              blocking_roll =
                if Map.has_key?(inner_by_r, r),
                  do: hd(inner_by_r[r]) - 1,
                  else: side - 1

              blocking_rock = find_down(side, c, rocks_by_r[r])

              new_c = Kernel.min(blocking_rock, blocking_roll)
              Map.update(inner_by_r, r, [new_c], fn l -> [new_c | l] end)
            end
          )
        end
      )

    # recreate the list of rolls by row and column
    for {r, l} <- new_rolls_by_r, c <- l, do: {r, c}
  end

  def part1(args) do
    {side, rocks, rolls} = args |> parse()

    move_north(rolls, side, map_by_rc(rocks))
    |> map(fn {r, _c} -> side - r end)
    |> sum()
  end

  def part2(args) do
    {side, rocks, rolls} = args |> parse()
    mapped_rocks = map_by_rc(rocks)

    # There is a starting period, then a succession of identical cycles
    # index_found is the index of the first time we find a state we've already seen
    # previous_index is the index of the first time we saw that state
    # Iterate forever
    {index_found, previous_index, visited} =
      Stream.iterate(1, &(&1 + 1))
      |> reduce_while(
        # Keep track of the last rolls, the set of visited rolls, and the map of index to rolls
        {rolls, MapSet.new(rolls), %{0 => rolls}},
        fn i, {rolls, visited, mapped_visited} ->
          # Move the rolls in all directions
          new_rolls =
            rolls
            |> move_north(side, mapped_rocks)
            |> move_west(side, mapped_rocks)
            |> move_south(side, mapped_rocks)
            |> move_east(side, mapped_rocks)
            |> MapSet.new()

          if new_rolls in visited do
            # Find the index of the first time we saw this state
            {index, _} = find(mapped_visited, fn {_p_i, p_rolls} -> p_rolls == new_rolls end)
            {:halt, {i, index, mapped_visited}}
          else
            {:cont,
             {new_rolls, MapSet.put(visited, new_rolls), Map.put(mapped_visited, i, new_rolls)}}
          end
        end
      )

    cycle_length = index_found - previous_index
    # Taking into account the first period (from 0 to previous_index)
    visited[rem(1_000_000_000 - previous_index, cycle_length) + previous_index]
    # Compute load
    |> map(fn {r, _c} -> side - r end)
    |> sum()
  end
end
