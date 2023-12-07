defmodule AdventOfCode.Day05 do
  import Enum

  @order ["soil", "fertilizer", "water", "light", "temperature", "humidity", "location"]

  def parse_block("seeds: " <> seeds) do
    seeds |> String.trim() |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)
  end

  # Block example:
  # seed-to-soil map:
  # 50 98 2
  # 52 50 48
  # will produce {"seed", [{{50,97}, {52,99}}, {{98,99}, {50,52}}]}
  # Note that I use {source, dest}, with low and high for intervals instead of {low, len}
  # Intervals are ordered by source (5à before 98 for example)
  def parse_block(block) do
    [f | r] = block |> String.split("\n", trim: true)
    [from, _to] = f |> String.replace(" map:", "") |> String.split("-to-", trim: true)

    maps =
      r
      |> map(fn triplet ->
        [dest, source, len] =
          triplet |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)

        # convert {low, len} to {low, high} and put source before dest in the tuple (simpler for me)
        {{source, source + len - 1}, {dest, dest + len - 1}}
      end)
      # Reorder
      |> sort_by(fn {{s, _}, _} -> s end)

    {from, maps}
  end

  def parse(args) do
    [seeds | blocks] = args |> String.split("\n\n") |> map(&parse_block/1)
    {seeds, Map.new(blocks)}
  end

  # Apply a map to a value
  def convert(from, value, maps) do
    # Is there a map?
    case find(maps[from], fn {{sl, sh}, _} -> value >= sl and value <= sh end) do
      # no -> identity
      nil -> value
      # yes -> apply the map
      {{source, _}, {dest, _}} -> value - source + dest
    end
  end

  # Apply the maps repeatdly to a seed value cycling over seed, soil, etc
  def to_location(seed, maps) do
    reduce(@order, {"seed", seed}, fn next_type, {current_type, current_value} ->
      {next_type, convert(current_type, current_value, maps)}
    end)
    |> elem(1)
  end

  # Part 1
  def part1(args) do
    {seeds, maps} = args |> parse()
    # map value of each seed and take the min
    seeds |> map(&to_location(&1, maps)) |> min()
  end

  # Part 2
  # The idea is that we're going to say that the image of an interval is a set of intervals

  # Image of an interval (not keeping the intervals where the map is an identity)
  # No itnersecrtion
  def cut({{a, _b}, _}, {_l, h}) when h < a, do: []
  def cut({{_a, b}, _}, {l, _h}) when l > b, do: []
  # overlap on the low side
  def cut({{a, b}, {da, db}}, {l, h}) when l < a and h <= b, do: [{a, h, da, db + h - b}]
  # total overlap
  def cut({{a, b}, {da, db}}, {l, h}) when l < a and h > b, do: [{a, b, da, db}]
  # inclusion
  def cut({{a, b}, {da, db}}, {l, h}) when l >= a and h <= b, do: [{l, h, da + l - a, db + h - b}]
  # overlap on the high side
  def cut({{a, b}, {da, db}}, {l, h}) when l >= a and h > b, do: [{l, b, da + l - a, db}]

  # the complex one !
  # Compute the image of an interval as a set of intervals, given the transformations in a_map
  def interval_mapping(a_map, {low, high}) do
    last_h = max(for {{_, h}, _} <- a_map, do: h)

    # Loop on each interval in the map (they are ordered, remember), inserting at the begining and between the intervals some identify functions intervals (like {a,b,a,b})
    to_intervals =
      reduce(
        a_map,
        [],
        fn {{a, _b}, _} = interval, acc ->
          # Add a first identity interval if needed
          if(acc == [] and low < a,
            do: acc ++ [{low, Kernel.min(a - 1, high), low, Kernel.min(a - 1, high)}],
            else: acc
          ) ++
            cut(interval, {low, high})
        end
      )

    # Add a last identity interval if needed
    to_intervals ++
      if high > last_h,
        do: [{Kernel.max(last_h + 1, low), high, Kernel.max(last_h + 1, low), high}],
        else: []
  end

  # Apply the previous function to a set of intervals (just accumulating the image of intervals)
  def intervals_to_intervals(intervals, a_map) do
    reduce(intervals, [], fn {l, h}, acc -> acc ++ interval_mapping(a_map, {l, h}) end)
    |> map(fn {_, _, da, db} -> {da, db} end)
  end

  # Apply all the transformations in a row
  def intervals_to_location(seed, maps) do
    reduce(@order, {"seed", seed}, fn next_type, {current_type, current_intervals} ->
      {next_type, intervals_to_intervals(current_intervals, maps[current_type])}
    end)
    |> elem(1)
  end

  def part2(args) do
    {seeds, maps} = args |> parse()

    # Apply the transformation for each interval
    for [low, len] <- chunk_every(seeds, 2) do
      # Take the minimum over each interval for one seed range
      intervals_to_location([{low, low + len - 1}], maps) |> map(&elem(&1, 0)) |> min()
    end
    # take the overall interval
    |> min()
  end
end
