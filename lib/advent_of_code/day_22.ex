defmodule AdventOfCode.Day22 do
  import Enum

  ### Parsing

  # Parse a list of integers separated by commas
  def intlist(l), do: l |> String.split(",", trim: true) |> map(&String.to_integer/1)
  # Parse a line
  def parse_line(line), do: String.split(line, "~") |> map(&intlist/1)

  # Parse the input
  def parse(args),
    do: args |> String.split("\n", trim: true) |> map(&parse_line/1)

  # Represents a brick with a tuple {z of the lowest point, height, list of [x, y] coordinates of the brick}
  def to_structure([[l, y, z], [h, y, z]]), do: {z, 1, for(i <- l..h, do: [i, y])}
  def to_structure([[x, l, z], [x, h, z]]), do: {z, 1, for(i <- l..h, do: [x, i])}
  def to_structure([[x, y, l], [x, y, h]]), do: {l, h - l + 1, [[x, y]]}

  # Convert a list of bricks to a list of structures
  def prepare(cubes), do: cubes |> map(&to_structure/1)

  ## Part 1 & 2

  # Sort cubes by their lowest point
  def sort_cubes(cubes), do: cubes |> Enum.sort_by(&elem(&1, 0))

  # Main function to fall the cubes
  def fall(sorted_cubes) do
    # Cubes have to be sorted by increasing lowest point
    sorted_cubes
    # Loop over the cubes
    # elevations: map of [x, y] coordinates to their elevation (keep a running map of the highest elevation of each x,y coordinate)
    # cubes: list of cubes that has been processed
    # moved: number of cubes that have been moved so far
    |> Enum.reduce({%{}, [], 0}, fn cube, {elevations, cubes, moved} ->
      {l, h, xys} = cube
      # Find the highest elevation found so far for the x,y of the cube
      highest = max(for([x, y] <- xys, do: Map.get(elevations, {x, y}, 0)))
      # Compute the new elevations for the x,y of the cube
      new_elevations =
        elevations |> Map.merge(for [x, y] <- xys, into: %{}, do: {{x, y}, highest + h})

      # If the cube is already at the highest elevation, add it to the list of processed cubes
      # else modify the elevation of the cube to the highest elevation + 1 and add it to the list of cubes to process
      # and increment the number of moved cubes
      if l == highest + 1,
        do: {new_elevations, [cube | cubes], moved},
        else: {new_elevations, [{highest + 1, h, xys} | cubes], moved + 1}
    end)
    # Return the list of processed cubes in a sorted order and the number of moved cubes
    |> then(fn {_, l, n} -> {reverse(l), n} end)
  end

  # Main function
  def run_simulations(cubes) do
    # Convert iinput to a list of structures, sort it by increasing lowest point and fall the cubes to their starting positions
    fell = cubes |> prepare() |> sort_cubes() |> fall() |> elem(0)

    # For each cube, remove it from the list of cubes and fall the remaining cubes and count the number of cubes that have fallen in each case
    for i <- 0..(length(fell) - 1) do
      fell |> List.delete_at(i) |> fall() |> elem(1)
    end
  end

  # Part 1
  def part1(args), do: args |> parse() |> run_simulations() |> filter(&(&1 == 0)) |> count()

  # Part 2
  def part2(args), do: args |> parse() |> run_simulations() |> sum()
end
