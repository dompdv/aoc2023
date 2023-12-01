defmodule AdventOfCode.Day05 do
  import Enum

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> map(&String.to_integer/1)
    |> with_index()
    |> map(fn {a, b} -> {b, a} end)
    |> Map.new()
  end

  def exec(pc, _, steps, _p_size) when pc < 0, do: steps
  def exec(pc, _, steps, p_size) when pc >= p_size, do: steps

  def exec(pc, program, steps, p_size) do
    jp = program[pc]
    exec(pc + jp, Map.put(program, pc, jp + 1), steps + 1, p_size)
  end

  def exec(program), do: exec(0, program, 0, count(program))

  def part1(args), do: exec(parse(args))

  def exec2(pc, _, steps, _p_size) when pc < 0, do: steps
  def exec2(pc, _, steps, p_size) when pc >= p_size, do: steps

  def exec2(pc, program, steps, p_size) do
    jp = program[pc]
    delta = if jp >= 3, do: -1, else: 1
    exec2(pc + jp, Map.put(program, pc, jp + delta), steps + 1, p_size)
  end

  def exec2(program), do: exec2(0, program, 0, count(program))

  def part2(args), do: exec2(parse(args))
end
