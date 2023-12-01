defmodule AdventOfCode.Day06 do
  import Enum

  def parse(args) do
    args
    |> String.trim()
    |> String.split()
    |> map(&String.to_integer/1)
    |> with_index(fn a, b -> {b, a} end)
    |> Map.new()
  end

  def most(banks) do
    reduce(banks, {-1, 0}, fn
      {_i, n}, {max_i, max_n} when n < max_n -> {max_i, max_n}
      {i, n}, {_max_i, max_n} when n > max_n -> {i, n}
      {i, n}, {max_i, max_n} when n == max_n and i < max_i -> {i, max_n}
      {i, n}, {max_i, max_n} when n == max_n and i > max_i -> {max_i, max_n}
    end)
  end

  def distribute(banks, seen, steps) do
    if MapSet.member?(seen, banks) do
      {steps, banks}
    else
      seen = MapSet.put(seen, banks)
      {max_i, max_n} = most(banks)
      banks = Map.put(banks, max_i, 0)

      banks =
        reduce(1..max_n, banks, fn i, b ->
          Map.put(b, rem(max_i + i, 16), b[rem(max_i + i, 16)] + 1)
        end)

      distribute(banks, seen, steps + 1)
    end
  end

  def distribute(banks), do: distribute(banks, MapSet.new(), 0)

  def part1(args), do: parse(args) |> distribute() |> elem(0)

  def part2(args), do: distribute(parse(args)) |> elem(1) |> distribute() |> elem(0)
end
