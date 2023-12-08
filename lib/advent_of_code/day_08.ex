defmodule AdventOfCode.Day08 do
  @lr %{?R => :right, ?L => :left}

  def parse_map(a_map) do
    a_map
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [a, b, c] = Regex.scan(~r/\w+/, line) |> List.flatten()
      {a, {b, c}}
    end)
    |> Map.new()
  end

  def parse(args) do
    [lr, a_map] = args |> String.split("\n\n", trim: true)
    lr = lr |> String.trim() |> to_charlist |> Enum.map(&Map.get(@lr, &1))
    {lr, parse_map(a_map)}
  end

  def hop(pos, :left, graph), do: graph[pos] |> elem(0)
  def hop(pos, :right, graph), do: graph[pos] |> elem(1)

  def part1(args) do
    {inst, graph} = args |> parse()

    Stream.cycle(inst)
    |> Enum.reduce_while({0, "AAA"}, fn dir, {counter, pos} ->
      next_pos = hop(pos, dir, graph)
      if next_pos == "ZZZ", do: {:halt, counter + 1}, else: {:cont, {counter + 1, next_pos}}
    end)
  end

  def part2(args) do
    {inst, graph} = args |> parse()
  end

  def test(_) do
    """
    RL

    AAA = (BBB, CCC)
    BBB = (DDD, EEE)
    CCC = (ZZZ, GGG)
    DDD = (DDD, DDD)
    EEE = (EEE, EEE)
    GGG = (GGG, GGG)
    ZZZ = (ZZZ, ZZZ)
    """
  end

  def test2(_),
    do: """
    LLR

    AAA = (BBB, BBB)
    BBB = (AAA, ZZZ)
    ZZZ = (ZZZ, ZZZ)
    """
end
