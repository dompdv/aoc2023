defmodule AdventOfCode.Day12 do
  import Enum

  def parse(records), do: records |> String.split("\n", trim: true) |> map(&parse_record/1)

  def parse_record(record) do
    [row, numbers] = String.split(record, " ", trim: true)
    numbers = numbers |> String.split(",", trim: true) |> map(&String.to_integer/1)
    {row |> to_charlist(), numbers}
  end

  # Memoization store

  def create_memoization_store() do
    # Delete the memoization store if it exists
    if :ets.whereis(:memo) != :undefined, do: :ets.delete(:memo)
    :ets.new(:memo, [:set, :protected, :named_table])
  end

  def store(value, key) do
    :ets.insert(:memo, {key, value})
    value
  end

  def retrieve(key) do
    case :ets.lookup(:memo, key) do
      [{_, result}] -> result
      [] -> nil
    end
  end

  # End of the characters
  # There is no more numbers and the counter is 0: we have a solution
  def solve([], 0, []), do: 1
  # There is no more numbers but the counter is not 0: dead end
  def solve([], _counter, []), do: 0
  # The remaining number is the current counter: we have a solution
  def solve([], counter, [counter]), do: 1
  # The remaining number is not the current counter: dead end
  def solve([], _counter, _numbers), do: 0

  # Processing a . character following another . or the start of the line: just move on
  def solve([?. | line], 0, numbers), do: solve(line, 0, numbers)

  # Processing a . character following a # character but there is no more "numbers" in the list: dead end
  def solve([?. | _line], _counter, []), do: 0

  # Processing a . character following a # character: compare the accumulated counter with the next number in the list. If different, dead end, else move on with the rest of the numbers
  def solve([?. | line], counter, [n | numbers]),
    do: if(counter != n, do: 0, else: solve(line, 0, numbers))

  # Processing a # character following another # or the start of the line, but with no numbers left: dead end
  def solve([?# | _line], _counter, []), do: 0

  # Processing a # character following another # or the start of the line: just move on
  def solve([?# | line], counter, [h | _] = numbers) do
    if counter >= h, do: 0, else: solve(line, counter + 1, numbers)
  end

  # Processing a ? character by adding the two cases
  def solve([?? | line] = l, counter, numbers) do
    # Try to retrieve from the memoization store
    case retrieve({l, counter, numbers}) do
      nil ->
        # If not found, compute the result (sum of the 2 cases: . or #) and store it
        (solve([?# | line], counter, numbers) + solve([?. | line], counter, numbers))
        |> store({l, counter, numbers})

      result ->
        result
    end
  end

  def solve({line, numbers}) do
    create_memoization_store()
    solve(line, 0, numbers)
  end

  def unfold_paper({line, numbers}) do
    {List.duplicate(line, 5) |> Enum.intersperse([??]) |> List.flatten(),
     List.duplicate(numbers, 5) |> List.flatten()}
  end

  def part1(args), do: args |> parse() |> map(&solve/1) |> sum()

  def part2(args), do: args |> parse() |> map(&unfold_paper/1) |> map(&solve/1) |> sum()
end
