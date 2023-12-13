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
      reduce_while(l, {0, []}, fn
        0, {0, acc} -> {:cont, {0, acc}}
        0, {x, acc} -> {:cont, {0, [x | acc]}}
        1, {x, acc} -> {:cont, {x + 1, acc}}
        ??, {x, acc} -> {:halt, {x, acc}}
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

  def solve_brute_force({line, numbers}) do
    qm = for {x, i} <- with_index(line), x == ??, do: i
    nqm = count(qm)

    Stream.map(0..(2 ** nqm - 1), fn v ->
      replacement = zip(qm, to_binary(v) |> pad_0(nqm)) |> Map.new()
      line |> replace(replacement) |> groups()
    end)
    |> Stream.filter(&(&1 == numbers))
    |> count()
  end

  def part1(args) do
    args |> parse() |> map(&solve_brute_force/1) |> sum()
  end

  def possibilities(replacement, [], line, numbers, _) do
    if line |> replace(replacement) |> groups() == numbers, do: 1, else: 0
  end

  def possibilities(replacement, [f | r], line, numbers, sn) do
    new_line = replace(line, replacement)

    if count(new_line, fn x -> x == 1 end) > sn do
      0
    else
      partials = groups(new_line)
      compare_to = slice(numbers, 0, length(partials))

      if partials > compare_to do
        0
      else
        for(i <- 0..1, do: possibilities(Map.put(replacement, f, i), r, line, numbers, sn))
        |> sum()
      end
    end
  end

  def solve2({line, numbers}) do
    sn = sum(numbers)
    [f | r] = for {x, i} <- with_index(line), x == ??, do: i
    replacement = %{}

    for(i <- 0..1, do: possibilities(Map.put(replacement, f, i), r, line, numbers, sn))
    |> sum()
  end

  def part2(args) do
    # |> map(&solve_brute_force/1) |> sum()
    args |> parse() |> map(&solve2/1) |> sum()
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
