defmodule AdventOfCode.Day12 do
  import Enum

  def parse(records), do: records |> String.split("\n", trim: true) |> map(&parse_record/1)

  def parse_record(record) do
    [row, numbers] = String.split(record, " ", trim: true)
    numbers = numbers |> String.split(",", trim: true) |> map(&String.to_integer/1)
    {row |> to_charlist(), numbers}
  end

  def solve([], {counter, acc}, numbers) do
    acc = if counter == 0, do: acc, else: acc ++ [counter]
    if acc == numbers, do: 1, else: 0
  end

  def solve([?. | line], {0, acc}, numbers),
    do: solve(line, {0, acc}, numbers)

  def solve([?. | line], {counter, acc}, numbers) do
    acc = acc ++ [counter]

    if acc > numbers,
      do: 0,
      else: solve(line, {0, acc}, numbers)
  end

  def solve([?# | line], {counter, acc}, numbers) do
    if acc ++ [counter + 1] > numbers,
      do: 0,
      else: solve(line, {counter + 1, acc}, numbers)
  end

  def solve([?? | line], {counter, acc}, numbers) do
    case0 =
      if counter == 0 do
        solve(line, {counter, acc}, numbers)
      else
        new_acc = acc ++ [counter]

        if new_acc > numbers,
          do: 0,
          else: solve(line, {0, new_acc}, numbers)
      end

    case1 =
      if acc ++ [counter + 1] > numbers,
        do: 0,
        else: solve(line, {counter + 1, acc}, numbers)

    case0 + case1
  end

  def solve({line, numbers}) do
    #    IO.inspect({line, numbers})
    # |> IO.inspect()
    solve(line, {0, []}, numbers)
  end

  def unfold_paper({line, numbers}) do
    {List.duplicate(line, 5) |> Enum.intersperse([??]) |> List.flatten(),
     List.duplicate(numbers, 5) |> List.flatten()}
  end

  def part1(args), do: args |> parse() |> map(&solve/1) |> sum()

  def part2(args), do: args |> test() |> parse() |> map(&unfold_paper/1) |> map(&solve/1) |> sum()

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
