defmodule AdventOfCode.Day08 do
  @lr %{?R => :right, ?L => :left}

  # Parse the graph into a map of nodes and their left/right neighbors
  def parse_graph(raw_graph) do
    raw_graph
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      Regex.scan(~r/\w+/, line) |> List.flatten() |> then(fn [a, b, c] -> {a, {b, c}} end)
    end)
    |> Map.new()
  end

  # Split first line into list of directions and the graph
  # directions are converted to atoms :right and :left
  # graph is parsed into a map of nodes and their left/right neighbors
  def parse(args) do
    [lr, raw_graph] = args |> String.split("\n\n", trim: true)
    lr = lr |> String.trim() |> to_charlist |> Enum.map(&Map.get(@lr, &1))
    {lr, parse_graph(raw_graph)}
  end

  # Hop to the left or right neighbor of a node
  def hop(pos, :left, graph), do: graph[pos] |> elem(0)
  def hop(pos, :right, graph), do: graph[pos] |> elem(1)

  # Same logic as part 1. The stop criteria is different: stop when we reach one of the end nodes
  def find_cycle_length({inst, graph}, start_node, end_keys) do
    inst
    |> Stream.cycle()
    |> Enum.reduce_while(
      {0, start_node},
      fn dir, {counter, pos} ->
        next_pos = hop(pos, dir, graph)

        if next_pos in end_keys,
          do: {:halt, counter + 1},
          else: {:cont, {counter + 1, next_pos}}
      end
    )
  end

  # Part 1
  def part1(args), do: args |> parse() |> find_cycle_length("AAA", ["ZZZ"])

  # Part 2 specific functions

  # smallest common multiple of a list of numbers
  def ppm([a, b]), do: div(a * b, Integer.gcd(a, b))
  def ppm([a, b | r]), do: ppm([div(a * b, Integer.gcd(a, b)) | r])

  # Part 2
  # The smallest global cycle length is the smallest common multiple of the cycle lengths of each node
  def part2(args) do
    {inst, graph} = args |> parse()

    # Find all start and end nodes
    nodes = Map.keys(graph)
    start_keys = Enum.filter(nodes, &String.ends_with?(&1, "A"))
    end_keys = Enum.filter(nodes, &String.ends_with?(&1, "Z"))

    start_keys
    |> Enum.map(&find_cycle_length({inst, graph}, &1, end_keys))
    |> ppm()
  end
end
