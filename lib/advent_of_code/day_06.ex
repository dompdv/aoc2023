defmodule AdventOfCode.Day06 do
  import Enum

  def parse1(args) do
    args
    |> String.split("\n", trim: true)
    |> map(fn line ->
      line |> String.split(" ", trim: true) |> drop(1) |> map(&String.to_integer/1)
    end)
    |> zip()
  end

  def parse2(args) do
    args
    |> String.split("\n", trim: true)
    |> map(fn line ->
      # remove all non-digits and convert to integer
      line |> String.replace(~r/\D|\s/, "") |> String.to_integer()
    end)
    |> List.to_tuple()
  end

  # to eliminate cases when the distance is exactly the previous record
  def up(i), do: if(trunc(i) == i, do: i + 1, else: :math.ceil(i))

  def down(i), do: if(trunc(i) == i, do: i - 1, else: :math.floor(i))

  # simple second degree equation
  def solve({time, dist}) do
    delta = :math.sqrt(time * time - 4 * dist)
    {low, high} = {(time - delta) / 2, (time + delta) / 2}
    trunc(down(high) - up(low) + 1)
  end

  def part1(args), do: args |> parse1() |> map(&solve/1) |> product()

  def part2(args), do: args |> parse2() |> solve()
end
