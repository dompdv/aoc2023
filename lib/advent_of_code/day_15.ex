defmodule AdventOfCode.Day15 do
  def parse_input(input) do
    [_, a, b] = Regex.run(~r/Generator A starts with (\d+)\nGenerator B starts with (\d+)/, input)
    {String.to_integer(a), String.to_integer(b)}
  end

  def next_value(value, factor), do: rem(value * factor, 2_147_483_647)

  def next_multiple_value(value, factor, m) do
    value = next_value(value, factor)
    if rem(value, m) == 0, do: value, else: next_multiple_value(value, factor, m)
  end

  def matching(a, b) when rem(a, 65536) == rem(b, 65536), do: 1
  def matching(_a, _b), do: 0

  def part1(args) do
    {a, b} = parse_input(args)

    Enum.reduce(1..40_000_000, {0, {a, b}}, fn _, {matches, {a, b}} ->
      {na, nb} = {next_value(a, 16_807), next_value(b, 48_271)}
      {matches + matching(na, nb), {na, nb}}
    end)
    |> elem(0)
  end

  def part2(args) do
    {a, b} = parse_input(args)

    Enum.reduce(1..5_000_000, {0, {a, b}}, fn _, {matches, {a, b}} ->
      {na, nb} = {next_multiple_value(a, 16_807, 4), next_multiple_value(b, 48_271, 8)}
      {matches + matching(na, nb), {na, nb}}
    end)
    |> elem(0)
  end
end
