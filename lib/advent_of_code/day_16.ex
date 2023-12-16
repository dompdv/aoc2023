defmodule AdventOfCode.Day16 do
  import Enum

  @directions %{north: {-1, 0}, south: {1, 0}, east: {0, 1}, west: {0, -1}}

  # PARSING
  def parse_char("."), do: :empty
  def parse_char("|"), do: :split_vertical
  def parse_char("-"), do: :split_horizontal
  def parse_char("/"), do: :mirror_right
  def parse_char("\\"), do: :mirror_left

  def parse_line(line, r) do
    line
    |> String.graphemes()
    |> with_index()
    |> map(fn {char, c} -> {{r, c}, parse_char(char)} end)
  end

  # Create a typical map %{{row,col} => :a_cell}
  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> with_index()
    |> map(fn {line, r} -> parse_line(line, r) end)
    |> List.flatten()
    |> Map.new()
  end

  def move({r, c}, dir) do
    {dr, dc} = @directions[dir]
    {r + dr, c + dc}
  end

  # Rules when entering a cell from a direction. Returns a list of directed light beams (pos, dir)
  # Empty => continue
  def enter(pos, dir, :empty), do: [{pos, dir}]
  # Split Horizontal
  def enter(pos, :east, :split_horizontal), do: [{pos, :east}]
  def enter(pos, :west, :split_horizontal), do: [{pos, :west}]
  def enter(pos, :north, :split_horizontal), do: [{pos, :west}, {pos, :east}]
  def enter(pos, :south, :split_horizontal), do: [{pos, :west}, {pos, :east}]
  # Split Vertical
  def enter(pos, :east, :split_vertical), do: [{pos, :north}, {pos, :south}]
  def enter(pos, :west, :split_vertical), do: [{pos, :north}, {pos, :south}]
  def enter(pos, :north, :split_vertical), do: [{pos, :north}]
  def enter(pos, :south, :split_vertical), do: [{pos, :south}]
  # Mirror Right
  def enter(pos, :east, :mirror_right), do: [{pos, :north}]
  def enter(pos, :west, :mirror_right), do: [{pos, :south}]
  def enter(pos, :north, :mirror_right), do: [{pos, :east}]
  def enter(pos, :south, :mirror_right), do: [{pos, :west}]
  # Mirror Left
  def enter(pos, :east, :mirror_left), do: [{pos, :south}]
  def enter(pos, :west, :mirror_left), do: [{pos, :north}]
  def enter(pos, :north, :mirror_left), do: [{pos, :west}]
  def enter(pos, :south, :mirror_left), do: [{pos, :east}]

  # Move the light beams one step forward
  # The idea is to keep track of the visited positions.
  # But a visited position is NOT ONLY THE POSITION, but also the DIRECTION OF THE BEAM
  # So it's a couple  {pos, dir}
  # THe idea is that, when a beam is about to enter a cell, we check if the couple {pos, dir} is already in the visited set.
  # If it is, we stop it, to avoid looping forever.

  # No beams left to move, compute the activated cells number
  def light(_, [], visited),
    # The MapSet.new() here is to deduplicate the visited positions (if they are several directions)
    do: visited |> map(fn {pos, _} -> pos end) |> MapSet.new() |> MapSet.size()

  # Move the beams one step forward
  def light(grid, [{pos, dir} | rest], visited) do
    new_pos = move(pos, dir)

    cond do
      # If the new position and direction is already visited, stop the beam
      {new_pos, dir} in visited ->
        light(grid, rest, visited)

      # outside the grid, stop the beam
      grid[new_pos] == nil ->
        light(grid, rest, visited)

      true ->
        # Compute the effects of entering the cell, given what's inside
        lights = enter(new_pos, dir, grid[new_pos])
        # Add the new position and beams to the list of beams to move
        # and add the new position and direction to the visited set
        light(grid, lights ++ rest, MapSet.put(visited, {new_pos, dir}))
    end
  end

  # Launch a beam into the grid from a given position and direction
  def beam(grid, pos, dir), do: light(grid, [{pos, dir}], MapSet.new())

  # Part 1
  def part1(args), do: args |> parse() |> beam({0, -1}, :east)

  # Part 2
  def part2(args) do
    grid = args |> parse()
    max_r = grid |> map(fn {{r, _}, _} -> r end) |> max()
    max_c = grid |> map(fn {{_, c}, _} -> c end) |> max()
    # Launch from the 4 sides
    [
      for(r <- 0..max_r, do: beam(grid, {r, -1}, :east)),
      for(r <- 0..max_r, do: beam(grid, {r, max_c + 1}, :west)),
      for(c <- 0..max_c, do: beam(grid, {-1, c}, :south)),
      for(c <- 0..max_c, do: beam(grid, {max_r + 1, c}, :north))
    ]
    |> List.flatten()
    |> max()
  end
end
