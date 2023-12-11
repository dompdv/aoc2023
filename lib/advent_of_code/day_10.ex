defmodule AdventOfCode.Day10 do
  import Enum

  @neighbors [{0, -1}, {0, 1}, {-1, 0}, {1, 0}]
  @dir [:west, :east, :north, :south]
  @delta_dir zip(@dir, @neighbors)

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

  def connex([], _, _, _, _), do: :in

  def connex([node | to_visit], component, graph, keys, cycle) do
    neighbors = map(@neighbors, fn d -> delta(node, d) end)

    if any?(neighbors, fn n -> n not in keys end) do
      :out
    else
      p = filter(neighbors, fn n -> n not in cycle and n not in component end)

      if any?(p, fn n -> graph[n] != [] end),
        do: :out,
        else: connex(to_visit ++ p, [node | component], graph, keys, cycle)
    end
  end

  def part2(args) do
    {graph, start} = args |> test4() |> parse()
    cycle = search_cycle([start], graph, []) |> MapSet.new() |> IO.inspect()
    print(graph, cycle)

    for(
      {cell, _} <- graph,
      graph[cell] == [],
      cell not in cycle,
      connex([cell], [cell], graph, Map.keys(graph), cycle) == :in,
      do: cell
    )

    #    |> count()
  end

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

  def secret_santa() do
    noms = ~w(diane dominique marius samuel mathilde annie noé isabelle)

    Stream.repeatedly(fn -> zip(noms, shuffle(noms)) end)
    |> Stream.filter(fn l -> all?(l, fn {a, b} -> a != b end) end)
    |> take(1)
  end
end
