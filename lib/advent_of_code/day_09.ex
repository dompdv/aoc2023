defmodule AdventOfCode.Day09 do
  import Enum

  def parse_line(line),
    do: line |> String.split(" ", trim: true) |> map(&String.to_integer/1)

  def parse(input), do: input |> String.split("\n", trim: true) |> map(&parse_line/1)

  def apply_diffs(l), do: apply_diffs(l, [l])

  def apply_diffs(l, acc) do
    d = l |> chunk_every(2, 1, :discard) |> map(fn [a, b] -> b - a end)
    if all?(d, &(&1 == 0)), do: acc, else: apply_diffs(d, [d | acc])
  end

  def predict1(steps), do: steps |> map(&List.last/1) |> sum()
  def predict2(steps), do: reduce(steps, 0, fn l, previous -> hd(l) - previous end)

  def part1(args),
    do: args |> parse() |> map(&apply_diffs/1) |> map(&predict1/1) |> sum()

  def part2(args),
    do: args |> parse() |> map(&apply_diffs/1) |> map(&predict2/1) |> sum()
end
