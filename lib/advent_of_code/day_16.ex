defmodule AdventOfCode.Day16 do
  import Enum

  @directions %{north: {-1, 0}, south: {1, 0}, east: {0, 1}, west: {0, -1}}
  @print %{
    empty: ".",
    split_vertical: "|",
    split_horizontal: "-",
    mirror_right: "/",
    mirror_left: "\\"
  }
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

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> with_index()
    |> map(fn {line, r} -> parse_line(line, r) end)
    |> List.flatten()
    |> Map.new()
    |> IO.inspect(label: "Parsed")
    |> print_grid()
  end

  def print_grid(grid) do
    max_r = grid |> map(fn {{r, _}, _} -> r end) |> max()
    max_c = grid |> map(fn {{_, c}, _} -> c end) |> max()

    for r <- 0..max_r do
      for c <- 0..max_c do
        @print[grid[{r, c}]]
      end
      |> join()
      |> IO.puts()
    end

    grid
  end

  def move({r, c}, dir) do
    {dr, dc} = @directions[dir]
    {r + dr, c + dc}
  end

  # Exit
  def enter(_pos, _dir, nil), do: []
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

  def light(_, [], visited), do: visited |> map(fn {pos, _} -> pos end) |> MapSet.new()

  def light(grid, [{pos, dir} | rest], visited) do
    new_pos = move(pos, dir)

    cond do
      {new_pos, dir} in visited ->
        light(grid, rest, visited)

      grid[new_pos] == nil ->
        light(grid, rest, visited)

      true ->
        lights = enter(new_pos, dir, grid[new_pos])
        light(grid, lights ++ rest, MapSet.put(visited, {new_pos, dir}))
    end
  end

  def part1(args) do
    args |> parse() |> light([{{0, -1}, :east}], MapSet.new()) |> MapSet.size()
  end

  def part2(_args) do
  end

  def test(_) do
    """
    .|...\\....
    |.-.\\.....
    .....|-...
    ........|.
    ..........
    .........\\
    ..../.\\\\..
    .-.-/..|..
    .|....-|.\\
    ..//.|....
    """
  end
end
