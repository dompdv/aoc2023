defmodule AdventOfCode.Day09 do
  def parse_line(line),
    do: line |> String.split(" ", trim: true) |> Enum.map(&String.to_integer/1)

  def parse(input), do: input |> String.split("\n", trim: true) |> Enum.map(&parse_line/1)

  def make_diff(l), do: l |> Enum.chunk_every(2, 1, :discard) |> Enum.map(fn [a, b] -> b - a end)

  def apply_diffs(l), do: apply_diffs(l, [l])
  def apply_diffs([_], acc), do: {:nok, acc}

  def apply_diffs(l, acc) do
    d = make_diff(l)
    if Enum.all?(d, &(&1 == 0)), do: acc, else: apply_diffs(d, [d | acc])
  end

  def predict(steps), do: steps |> Enum.map(&List.last/1) |> Enum.sum()

  def part1(args) do
    args |> parse() |> Enum.map(&apply_diffs/1) |> Enum.map(&predict/1) |> Enum.sum()
  end

  def part2(_args) do
  end

  def test(_),
    do: """
    0 3 6 9 12 15
    1 3 6 10 15 21
    10 13 16 21 30 45
    """
end
