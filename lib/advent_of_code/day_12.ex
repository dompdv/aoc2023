defmodule AdventOfCode.Day12 do
  import Enum

  def parse(records), do: records |> String.split("\n", trim: true) |> map(&parse_record/1)

  def parse_record(record) do
    [row, numbers] = String.split(record, " ", trim: true)
    numbers = numbers |> String.split(",", trim: true) |> map(&String.to_integer/1)

    row =
      row
      |> String.replace("#", "1")
      |> String.replace(".", "0")
      |> to_charlist()
      |> map(fn
        ?? -> ??
        c -> c - ?0
      end)

    {row, numbers}
  end

  def group_consecutive(l) do
    {x, c, acc} =
      reduce(l, {nil, 0, []}, fn
        x, {nil, 0, []} -> {x, 1, []}
        x, {x, c, acc} -> {x, c + 1, acc}
        x, {y, c, acc} -> {x, 1, [{y, c} | acc]}
      end)

    reverse([{x, c} | acc])
  end

  def groups(l) do
    {x, acc} =
      reduce(l, {0, []}, fn
        0, {0, acc} -> {0, acc}
        0, {x, acc} -> {0, [x | acc]}
        1, {x, acc} -> {x + 1, acc}
      end)

    reverse(if x == 0, do: acc, else: [x | acc])
  end

  def pad_0(l, q) do
    if length(l) < q, do: pad_0([0 | l], q), else: l
  end

  def to_binary(i), do: to_binary(i, [])
  def to_binary(0, acc), do: [0 | acc]
  def to_binary(1, acc), do: [1 | acc]
  def to_binary(i, acc), do: to_binary(div(i, 2), [rem(i, 2) | acc])

  def replace(line, replacement) do
    for {c, i} <- with_index(line), do: Map.get(replacement, i, c)
  end

  def solve({line, numbers}) do
    qm = for {x, i} <- with_index(line), x == ??, do: i
    nqm = count(qm)

    Stream.map(0..(2 ** nqm - 1), fn v ->
      replacement = zip(qm, to_binary(v) |> pad_0(nqm)) |> Map.new()
      new_line = replace(line, replacement)
      groups(new_line)
    end)
    |> Stream.filter(&(&1 == numbers))
    |> count()
  end

  def part1(args) do
    args |> parse() |> map(&solve/1) |> sum()
  end

  def part2(_args) do
  end

  def test(_) do
    """
    ???.### 1,1,3
    .??..??...?##. 1,1,3
    ?#?#?#?#?#?#?#? 1,3,1,6
    ????.#...#... 4,1,1
    ????.######..#####. 1,6,5
    ?###???????? 3,2,1
    """
  end
end
