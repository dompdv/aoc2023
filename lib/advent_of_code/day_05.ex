defmodule AdventOfCode.Day05 do
  import Enum

  @order ["soil", "fertilizer", "water", "light", "temperature", "humidity", "location"]
  @max_int 2_453_327_846_000_000_000

  def parse_block("seeds: " <> seeds) do
    seeds |> String.trim() |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)
  end

  def parse_block(block) do
    [f | r] = block |> String.split("\n", trim: true)
    [from, _to] = f |> String.replace(" map:", "") |> String.split("-to-", trim: true)

    maps =
      map(r, fn triplet ->
        triplet |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)
      end)

    {from, maps}
  end

  def parse(args) do
    [seeds | blocks] = args |> String.split("\n\n") |> map(&parse_block/1)
    {seeds, Map.new(blocks)}
  end

  def convert(from, value, maps) do
    the_map = maps[from]

    case find(the_map, fn [_, s, l] -> s <= value and value < s + l end) do
      [d, s, _] -> value - s + d
      nil -> value
    end
  end

  def to_location(seed, maps) do
    reduce(@order, {"seed", seed}, fn next_type, {current_type, current_value} ->
      {next_type, convert(current_type, current_value, maps)}
    end)
    |> elem(1)
  end

  def part1(args) do
    {seeds, maps} = args |> parse()
    reduce(seeds, @max_int, fn s, acc -> Kernel.min(to_location(s, maps), acc) end)
  end

  def part2(args) do
    {seeds, maps} = args |> parse()

    for [s, l] <- chunk_every(seeds, 2) do
      reduce(s..(s + l - 1), @max_int, fn s, acc -> Kernel.min(to_location(s, maps), acc) end)
    end
    |> min()
  end
end
