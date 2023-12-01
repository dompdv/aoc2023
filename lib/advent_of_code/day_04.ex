defmodule AdventOfCode.Day04 do
  import Enum

  def check_unique(line), do: count(uniq(line)) == count(line)

  def is_anagram(w1, w2), do: sort(to_charlist(w1)) == sort(to_charlist(w2))

  def check_valid(line) do
    not any?(
      for {w1, i1} <- with_index(line),
          {w2, i2} <- with_index(line),
          i1 < i2,
          do: is_anagram(w1, w2)
    )
  end

  def parse(args),
    do:
      args
      |> String.split("\n", trim: true)
      |> map(fn line -> String.split(line, " ", trim: true) end)

  def part1(args), do: parse(args) |> count(&check_unique(&1))
  def part2(args), do: parse(args) |> count(&check_valid(&1))
end
