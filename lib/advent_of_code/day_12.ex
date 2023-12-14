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

  def solve3([], {counter, acc}, numbers) do
    acc = if counter == 0, do: acc, else: acc ++ [counter]
    if acc == numbers, do: 1, else: 0
  end

  def solve3([0 | line], {0, acc}, numbers),
    do: solve3(line, {0, acc}, numbers)

  def solve3([0 | line], {counter, acc}, numbers) do
    acc = acc ++ [counter]

    if acc > numbers,
      do: 0,
      else: solve3(line, {0, acc}, numbers)
  end

  def solve3([1 | line], {counter, acc}, numbers) do
    if acc ++ [counter + 1] > numbers,
      do: 0,
      else: solve3(line, {counter + 1, acc}, numbers)
  end

  def solve3([?? | line], {counter, acc}, numbers) do
    case0 =
      if counter == 0 do
        solve3(line, {counter, acc}, numbers)
      else
        new_acc = acc ++ [counter]

        if new_acc > numbers,
          do: 0,
          else: solve3(line, {0, new_acc}, numbers)
      end

    case1 =
      if acc ++ [counter + 1] > numbers,
        do: 0,
        else: solve3(line, {counter + 1, acc}, numbers)

    case0 + case1
  end

  def solve3({line, numbers}) do
    solve3(line, {0, []}, numbers)
  end

  def unfold_paper({line, numbers}) do
    {List.duplicate(line, 5) |> Enum.intersperse([??]) |> List.flatten(),
     List.duplicate(numbers, 5) |> List.flatten()}
  end

  def part2(args) do
    # |> map(&solve_brute_force/1) |> sum()
    # args |> parse() |> test() |> map(fn row -> row |> unfold_paper() |> solve3() end) |> sum()
    #    args |> test() |> parse() |> hd() |> solve3()
    args |> test() |> parse() |> map(&unfold_paper/1) |> map(&solve3/1) |> sum()
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
