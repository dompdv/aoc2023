defmodule AdventOfCode.Day15 do
  import Enum

  def hash(item), do: hash(to_charlist(item), 0)
  def hash([], v), do: v
  def hash([13 | t], v), do: hash(t, v)
  def hash([h | t], v), do: hash(t, rem((v + h) * 17, 256))

  def part1(args) do
    "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"

    args
    |> String.replace("\n", "")
    |> String.split(",", trim: true)
    |> map(&hash/1)
    |> sum()
  end

  def part2(_args) do
  end
end
