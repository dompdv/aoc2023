defmodule AdventOfCode.Day09 do
  def analyze([], state, level, score, collected),
    do: {state, level, score, collected}

  def analyze([?, | s], :in_group, level, score, collected),
    do: analyze(s, :in_group, level, score, collected)

  def analyze([?{ | s], :in_group, level, score, collected),
    do: analyze(s, :in_group, level + 1, score, collected)

  def analyze([?} | s], :in_group, level, score, collected),
    do: analyze(s, :in_group, level - 1, score + level, collected)

  def analyze([?< | s], :in_group, level, score, collected),
    do: analyze(s, :in_garbage, level, score, collected)

  def analyze([?!, _ | s], :in_garbage, level, score, collected),
    do: analyze(s, :in_garbage, level, score, collected)

  def analyze([?> | s], :in_garbage, level, score, collected),
    do: analyze(s, :in_group, level, score, collected)

  def analyze([_ | s], :in_garbage, level, score, collected),
    do: analyze(s, :in_garbage, level, score, collected + 1)

  def analyze(s), do: analyze(s, :in_group, 0, 0, 0)

  def part1(args), do: String.trim(args) |> to_charlist() |> analyze() |> elem(2)
  def part2(args), do: String.trim(args) |> to_charlist() |> analyze() |> elem(3)
end
