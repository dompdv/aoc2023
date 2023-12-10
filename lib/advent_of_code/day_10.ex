defmodule AdventOfCode.Day10 do
  import Enum

  @dir [:west, :east, :north, :south]
  @delta_dir [{:west, {0, -1}}, {:east, {0, 1}}, {:north, {-1, 0}}, {:south, {1, 0}}]

  def parse_line(line) do
    line
    |> to_charlist()
    |> Enum.map(fn
      ?. -> []
      ?- -> [:east, :west]
      ?| -> [:south, :north]
      ?L -> [:north, :east]
      ?J -> [:north, :west]
      ?7 -> [:south, :west]
      ?F -> [:south, :east]
      ?S -> :start
    end)
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

  def search_cycle([], _, visited), do: visited

  def search_cycle([node | to_visit], graph, visited) do
    if node in visited,
      do: search_cycle(to_visit, graph, visited),
      else: search_cycle(connected_nodes(graph, node) ++ to_visit, graph, [node | visited])
  end

  def part1(args) do
    {graph, start} = args |> parse()
    search_cycle([start], graph, []) |> length() |> div(2)
  end

  def part2(_args) do
  end

  def test(_) do
    """
    .....
    .S-7.
    .|.|.
    .L-J.
    .....
    """
  end

  def test2(_) do
    """
    ..F7.
    .FJ|.
    SJ.L7
    |F--J
    LJ...
    """
  end

  def test3(_) do
    """
    -L|F7
    7S-7|
    L|7||
    -L-J|
    L|-JF
    """
  end

  def secret_santa() do
    noms = ~w(diane dominique marius samuel mathilde annie noé isabelle)

    Stream.repeatedly(fn -> zip(noms, shuffle(noms)) end)
    |> Stream.filter(fn l -> all?(l, fn {a, b} -> a != b end) end)
    |> take(1)
  end
end
