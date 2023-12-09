defmodule AdventOfCode.Day09 do
  def parse_line(line),
    do: line |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)

  def parse(input), do: input |> String.split("\n", trim: true) |> Enum.map(&parse_line/1)

  def apply_diffs(l), do: apply_diffs(l, [l])

  def apply_diffs(l, acc) do
    d = l |> Enum.chunk_every(2, 1, :discard) |> Enum.map(fn [a, b] -> b - a end)
    if Enum.all?(d, &(&1 == 0)), do: acc, else: apply_diffs(d, [d | acc])
  end

  def predict1(steps), do: steps |> Enum.map(&List.last/1) |> Enum.sum()
  def predict2(steps), do: Enum.reduce(steps, 0, fn l, previous -> hd(l) - previous end)

  def part1(args),
    do: args |> parse() |> Enum.map(&apply_diffs/1) |> Enum.map(&predict1/1) |> Enum.sum()

  def part2(args),
    do: args |> parse() |> Enum.map(&apply_diffs/1) |> Enum.map(&predict2/1) |> Enum.sum()
end
