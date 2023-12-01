defmodule AdventOfCode.Day13 do
  import Enum

  def parse_line(line),
    do: line |> String.split(": ", trim: true) |> map(&String.to_integer/1) |> List.to_tuple()

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> map(&parse_line/1)
    |> Map.new()
  end

  def part1(args) do
    args
    |> parse()
    |> Enum.reduce(0, fn {i, m}, score ->
      # the magic happens here. We use the fact that there is a loop of size 2 * (m - 1)
      # and we can calculate the position of the scanner at time i by doing rem(i, 2 * (m - 1))
      score +
        if rem(i, 2 * (m - 1)) == 0,
          do: i * m,
          else: 0
    end)
  end

  def caught?(fw, delay) do
    Enum.reduce_while(fw, false, fn {i, m}, _ ->
      if rem(delay + i, 2 * (m - 1)) == 0,
        do: {:halt, true},
        else: {:cont, false}
    end)
  end

  def while_caught(fw, delay) do
    if caught?(fw, delay),
      do: while_caught(fw, delay + 1),
      else: delay
  end

  def part2(args), do: args |> parse() |> while_caught(0)
end
