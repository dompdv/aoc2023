defmodule AdventOfCode.Day17 do
  import Enum

  @directions %{n: {-1, 0}, s: {1, 0}, e: {0, 1}, w: {0, -1}}
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

  def find_minimum_node(distances, to_visit) do
    distances
    |> filter(fn {pos, _} -> pos in to_visit end)
    |> reduce(fn {pos, {dist, _lm}} = p, {_mp, {min_dist, _mlm}} = minp ->
      if dist < min_dist,
        do: p,
        else: minp
    end)
  end

  def to_pos(directions, {r, c}, grid) do
    reduce(directions, [], fn dir, acc ->
      {dr, dc} = @directions[dir]
      new_pos = {r + dr, c + dc}

      if Map.has_key?(grid, new_pos),
        do: [{new_pos, dir} | acc],
        else: acc
    end)
  end

  def find_neighbours(pos, [], grid), do: [:n, :s, :e, :w] |> to_pos(pos, grid)
  def find_neighbours(pos, [:n, :n, :n | _], grid), do: [:e, :w] |> to_pos(pos, grid)
  def find_neighbours(pos, [:s, :s, :s | _], grid), do: [:e, :w] |> to_pos(pos, grid)
  def find_neighbours(pos, [:e, :e, :e | _], grid), do: [:n, :s] |> to_pos(pos, grid)
  def find_neighbours(pos, [:w, :w, :w | _], grid), do: [:n, :s] |> to_pos(pos, grid)
  def find_neighbours(pos, [:n | _], grid), do: [:n, :e, :w] |> to_pos(pos, grid)
  def find_neighbours(pos, [:s | _], grid), do: [:s, :e, :w] |> to_pos(pos, grid)
  def find_neighbours(pos, [:e | _], grid), do: [:e, :n, :s] |> to_pos(pos, grid)
  def find_neighbours(pos, [:w | _], grid), do: [:w, :n, :s] |> to_pos(pos, grid)

  def dj(to_visit, distances, grid) do
    if MapSet.size(to_visit) == 0 do
      distances
    else
      {min_pos, {min_dist, last_moves}} =
        find_minimum_node(distances, to_visit)

      to_visit = MapSet.delete(to_visit, min_pos)

      new_distances =
        find_neighbours(min_pos, last_moves, grid)
        # |> IO.inspect(label: "Neighbours:")
        |> reduce(
          distances,
          fn {pos, move_to}, acc ->
            weight = grid[pos]
            dist_b = acc[pos] |> elem(0)

            if dist_b > min_dist + weight,
              do: Map.put(acc, pos, {min_dist + weight, [move_to | last_moves]}),
              else: acc
          end
        )

      # IO.inspect({to_visit, new_distances}, label: "New state:")

      dj(to_visit, new_distances, grid)
    end
  end

  def dj(grid) do
    maximum = count(grid) * 10
    outside = for {pos, _} <- grid, into: %{}, do: {pos, {maximum, []}}
    dj(MapSet.new(Map.keys(grid)), Map.put(outside, {0, 0}, {0, []}), grid)
  end

  def part1(args) do
    grid = args |> parse()
    max_r = grid |> map(fn {{r, _}, _} -> r end) |> max()
    max_c = grid |> map(fn {{_, c}, _} -> c end) |> max()
    dj(grid) |> Map.get({max_r, max_c})
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

  def test2(_) do
    """
    119
    911
    """
  end
end
