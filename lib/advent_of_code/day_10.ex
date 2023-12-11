defmodule AdventOfCode.Day10 do
  import Enum

  @neighbors [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]
  @dir [:west, :east, :north, :south]
  @delta_dir zip(@dir, @neighbors)

  def print(graph, cycle) do
    columns = for({{_, c}, _} <- graph, do: c) |> max()
    rows = for({{r, _}, _} <- graph, do: r) |> max()

    for r <- 0..rows do
      for c <- 0..columns do
        cell = {r, c}

        if cell in cycle,
          do: IO.write("X"),
          else: IO.write(if graph[cell] == [], do: ".", else: "#")
      end

      IO.puts("")
    end
  end

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
    connected = connected_nodes(graph, node) |> filter(fn n -> n not in visited end)

    if connected == [],
      do: search_cycle(to_visit, graph, [node | visited]),
      else: search_cycle([hd(connected) | to_visit], graph, [node | visited])
  end

  def part1(args) do
    {graph, start} = args |> parse()
    search_cycle([start], graph, []) |> length() |> div(2)
  end

  def segments(l), do: chunk_every(l ++ [hd(l)], 2, 1)

  def part2(args) do
    {graph, start} = args |> test() |> parse()
    cycle = search_cycle([start], graph, []) |> IO.inspect()
    print(graph, cycle)
    cycle |> IO.inspect() |> segments() |> IO.inspect()
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
    ...........
    .S-------7.
    .|F-----7|.
    .||.....||.
    .||.....||.
    .|L-7.F-J|.
    .|..|.|..|.
    .L--J.L--J.
    ...........
    """
  end

  def test3(_) do
    """
    FF7FSF7F7F7F7F7F---7
    L|LJ||||||||||||F--J
    FL-7LJLJ||||||LJL-77
    F--JF--7||LJLJIF7FJ-
    L---JF-JLJIIIIFJLJJ7
    |F|F-JF---7IIIL7L|7|
    |FFJF7L7F-JF7IIL---7
    7-L-JL7||F7|L7F-7F7|
    L.L7LFJ|||||FJL7||LJ
    L7JLJL-JLJLJL--JLJ.L
    """
  end

  def test4(_) do
    """
    .F----7F7F7F7F-7....
    .|F--7||||||||FJ....
    .||.FJ||||||||L7....
    FJL7L7LJLJ||LJ.L-7..
    L--J.L7...LJS7F-7L7.
    ....F-J..F7FJ|L7L7L7
    ....L7.F7||L7|.L7L7|
    .....|FJLJ|FJ|F7|.LJ
    ....FJL-7.||.||||...
    ....L---J.LJ.LJLJ...
    """
  end
end
