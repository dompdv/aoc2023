defmodule AdventOfCode.Day10 do
  import Enum

  @neighbors [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]
  @dir [:west, :east, :north, :south]
  @delta_dir zip(@dir, @neighbors)

  @cell_types %{
    ?. => [],
    ?- => [:east, :west],
    ?| => [:south, :north],
    ?L => [:north, :east],
    ?J => [:north, :west],
    ?7 => [:south, :west],
    ?F => [:south, :east],
    ?S => :start
  }

  def parse_line(line) do
    line
    |> to_charlist()
    |> Enum.map(&@cell_types[&1])
    |> with_index()
  end

  def parse(input) do
    graph =
      input
      |> String.split("\n", trim: true)
      |> with_index()
      |> map(fn {line, r} -> parse_line(line) |> map(fn {cell, c} -> {{r, c}, cell} end) end)
      |> List.flatten()
      |> Map.new()

    {graph, graph |> Enum.find(fn {_, v} -> v == :start end) |> elem(0)}
  end

  def delta({r, c}, {dr, dc}), do: {r + dr, c + dc}
  def check_connected(:east, :west), do: true
  def check_connected(:west, :east), do: true
  def check_connected(:north, :south), do: true
  def check_connected(:south, :north), do: true
  def check_connected(_, _), do: false

  def connected_nodes(graph, position) do
    # take all the directions from the current cell
    graph[position]
    |> then(fn
      # if start, potential directions are all
      :start -> @dir
      dirs -> dirs
    end)
    |> map(fn dir ->
      # retrieve the adjacent cell in the given direction
      adjacent_cell = delta(position, @delta_dir[dir])
      connections = Map.get(graph, adjacent_cell, [])

      # if the adjacent cell is connected to the current cell, return it
      if connections == :start or any?(connections, &check_connected(dir, &1)),
        do: adjacent_cell,
        else: nil
    end)
    |> filter(&(&1 != nil))
  end

  def reveal_start(graph, start) do
    @dir
    |> map(fn dir ->
      adjacent_cell = delta(start, @delta_dir[dir])
      connections = Map.get(graph, adjacent_cell, [])

      if any?(connections, &check_connected(dir, &1)),
        do: dir,
        else: nil
    end)
    |> filter(&(&1 != nil))
  end

  def search_cycle([], _, visited), do: visited

  def search_cycle([node | to_visit], graph, visited) do
    connected = connected_nodes(graph, node) |> filter(fn n -> n not in visited end)

    if connected == [],
      do: search_cycle(to_visit, graph, [node | visited]),
      else: search_cycle([hd(connected) | to_visit], graph, [node | visited])
  end

  def part1(args) do
    {graph, start} = args |> parse()
    search_cycle([start], graph, []) |> length() |> div(2)
  end

  # Point A : start of the semi-line, V1 : direction of the semi-line, Point 1 and 2 : segment
  def intersect({xa, ya}, {xv1, yv1}, {x1, y1}, {x2, y2}) do
    {xv2, yv2} = {x2 - x1, y2 - y1}
    num = (xa - x1) * yv2 - (ya - y1) * xv2
    den = xv2 * yv1 - yv2 * xv1
    t = num / den

    # Check if the intersection point is on the semi-line
    if t >= 0 do
      # Check if the intersection point is on the segment
      {xi, yi} = {xa + xv1 * t, ya + yv1 * t}
      (x1 - xi) * (x2 - xi) + (y1 - yi) * (y2 - yi) <= 0
    else
      false
    end
  end

  # Draw precise segments (with 0.5 offset)
  def to_segment(graph, {r, c} = cell) do
    map(
      graph[cell],
      fn
        :east -> {{r + 0.5, c + 0.5}, {r + 0.5, c + 1}}
        :west -> {{r + 0.5, c + 0.5}, {r + 0.5, c}}
        :north -> {{r + 0.5, c + 0.5}, {r, c + 0.5}}
        :south -> {{r + 0.5, c + 0.5}, {r + 1, c + 0.5}}
      end
    )
  end

  # Accumulate segments for all the cells in a list (here in the cycle)
  def to_segments(graph, l), do: map(l, &to_segment(graph, &1)) |> List.flatten()

  def count_intersections(start, direction, segments) do
    segments
    |> map(fn {p1, p2} -> intersect(start, direction, p1, p2) end)
    |> filter(& &1)
    |> length()
  end

  # Offset the start point and choose a direction which is not parallel to the axes and with very low probably to encounter a (0.5) point (wich would be a corner, thus on 2 segments)
  def count_intersections({r, c}, segments),
    do: count_intersections({r + 0.509, c + 0.49}, {2.28787, 1.33424545}, segments)

  def odd?(n), do: rem(n, 2) == 1

  def part2(args) do
    {graph, start} = args |> parse()
    # Change the start cell to its real shape
    graph = Map.put(graph, start, reveal_start(graph, start))
    # Identify the cycle
    cycle = search_cycle([start], graph, [])
    # compute the segments
    segments = to_segments(graph, cycle)

    # For each node in the cycle, count the number of intersections with the segments. If odd, it an inside point
    graph
    |> filter(fn {c, _} -> c not in cycle end)
    |> filter(fn {cell, _v} -> odd?(count_intersections(cell, segments)) end)
    |> length()
  end
end
