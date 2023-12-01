defmodule AdventOfCode.Day08 do
  import Enum

  @expr ~r/(.+) (inc|dec) (-?\d+) if (.+) (!=|==|>=|<=|>|<) (.+)/

  def inc(registers, register, value),
    do: Map.put(registers, register, Map.get(registers, register, 0) + value)

  def dec(registers, register, value),
    do: Map.put(registers, register, Map.get(registers, register, 0) - value)

  def parse_line(line) do
    [r_t, op, offset, r_cond, comp, threshold] = Regex.run(@expr, line, capture: :all_but_first)

    {
      r_t,
      if(op == "inc", do: &inc/3, else: &dec/3),
      String.to_integer(offset),
      r_cond,
      case comp do
        "!=" -> &(&1 != &2)
        "==" -> &(&1 == &2)
        ">=" -> &(&1 >= &2)
        ">" -> &(&1 > &2)
        "<=" -> &(&1 <= &2)
        "<" -> &(&1 < &2)
      end,
      String.to_integer(threshold)
    }
  end

  def parse(args),
    do:
      args
      |> String.split("\n", trim: true)
      |> map(&parse_line/1)
      |> with_index(fn e, i -> {i, e} end)
      |> Map.new()

  def execute(pc, registers, highest, program) do
    if pc >= count(program) do
      {registers, highest}
    else
      {register, incdec, value, r_cond, op, threshold} = program[pc]

      registers =
        if op.(Map.get(registers, r_cond, 0), threshold),
          do: incdec.(registers, register, value),
          else: registers

      highest = Kernel.max(highest, Map.get(registers, register, 0))
      execute(pc + 1, registers, highest, program)
    end
  end

  def execute(program), do: execute(0, %{}, 0, program)

  def part1(args), do: parse(args) |> execute() |> elem(0) |> Map.values() |> max()

  def part2(args), do: parse(args) |> execute() |> elem(1)
end
