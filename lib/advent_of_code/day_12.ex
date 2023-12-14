defmodule AdventOfCode.Day12 do
  import Enum

  def parse(records), do: records |> String.split("\n", trim: true) |> map(&parse_record/1)

  def parse_record(record) do
    [row, numbers] = String.split(record, " ", trim: true)
    numbers = numbers |> String.split(",", trim: true) |> map(&String.to_integer/1)
    {row |> to_charlist(), numbers}
  end

  # End of the characters
  def solve([], 0, []), do: 1

  def solve([], _counter, []), do: 0

  def solve([], counter, [counter]), do: 1
  def solve([], _counter, _numbers), do: 0

  # Processing a . character following another . or the start of the line: just move on
  def solve([?. | line], 0, numbers),
    do: solve(line, 0, numbers)

  # Processing a . character following a # character but there is no more "numbers" in the list: dead end
  def solve([?. | _line], _counter, []), do: 0

  # Processing a . character following a # character: compare the accumulated counter with the next number in the list. If different, dead end, else move on with the rest of the numbers
  def solve([?. | line], counter, [n | numbers]) do
    if counter != n, do: 0, else: solve(line, 0, numbers)
  end

  # Processing a # character following another # or the start of the line, but with no numbers left: dead end
  def solve([?# | _line], _counter, []), do: 0

  # Processing a # character following another # or the start of the line: just move on
  def solve([?# | line], counter, numbers) do
    solve(line, counter + 1, numbers)
  end

  # Processing a ? character adding the two cases
  def solve([?? | line], counter, numbers) do
    solve([?. | line], counter, numbers) + solve([?# | line], counter, numbers)
  end

  def solve({line, numbers}) do
    #    IO.inspect({line, numbers})
    solve(line, 0, numbers)
  end

  def unfold_paper({line, numbers}) do
    {List.duplicate(line, 5) |> Enum.intersperse([??]) |> List.flatten(),
     List.duplicate(numbers, 5) |> List.flatten()}
  end

  def part1(args), do: args |> parse() |> map(&solve/1) |> sum()

  def part2(args), do: args |> parse() |> map(&unfold_paper/1) |> map(&solve/1) |> sum()

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
