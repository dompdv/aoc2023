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

    start_keys =
      Map.keys(graph) |> Enum.filter(fn key -> String.ends_with?(key, "A") end)

    end_keys =
      Map.keys(graph) |> Enum.filter(fn key -> String.ends_with?(key, "Z") end) |> MapSet.new()

    {start_keys, end_keys} |> IO.inspect(label: "start/end keys")

    s = Enum.at(start_keys, 2)

    inst
    |> Enum.with_index()
    |> Stream.cycle()
    |> Enum.reduce_while(
      {0, s, MapSet.new(), []},
      fn {dir, c}, {counter, pos, final_states, z_states} ->
        next_pos = hop(pos, dir, graph)

        if MapSet.member?(final_states, {next_pos, c}) do
          {:halt, {counter + 1, next_pos, c, final_states, z_states}}
        else
          z_states =
            if MapSet.member?(end_keys, next_pos),
              do: [counter + 1 | z_states],
              else: z_states

          final_states =
            if MapSet.member?(end_keys, next_pos),
              do: MapSet.put(final_states, {next_pos, c}),
              else: final_states

          {:cont, {counter + 1, next_pos, final_states, z_states}}
        end
      end
    )
  end

  def part21(args) do
    {inst, graph} = args |> test3() |> parse()

    start_keys =
      Map.keys(graph) |> Enum.filter(fn key -> String.ends_with?(key, "A") end)

    end_keys =
      Map.keys(graph) |> Enum.filter(fn key -> String.ends_with?(key, "Z") end) |> MapSet.new()

    Stream.cycle(inst)
    |> Enum.reduce_while({0, start_keys}, fn dir, {counter, pos} ->
      next_pos = Enum.map(pos, fn p -> hop(p, dir, graph) end)

      if Enum.all?(next_pos, fn p -> MapSet.member?(end_keys, p) end),
        do: {:halt, counter + 1},
        else: {:cont, {counter + 1, next_pos}}
    end)

    {start_keys, end_keys}
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

  def test3(_),
    do: """
    LR

    11A = (11B, XXX)
    11B = (XXX, 11Z)
    11Z = (11B, XXX)
    22A = (22B, XXX)
    22B = (22C, 22C)
    22C = (22Z, 22Z)
    22Z = (22B, 22B)
    XXX = (XXX, XXX)
    """
end
