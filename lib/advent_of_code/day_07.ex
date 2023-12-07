defmodule AdventOfCode.Day07 do
  @card_values for(c <- ?2..?9, into: %{}, do: {c, c - ?0})
               |> Map.merge(%{?T => 10, ?J => 11, ?Q => 12, ?K => 13, ?A => 14})

  def find_type(charl) do
    a = charl |> Enum.frequencies() |> Map.values() |> Enum.sort(:desc)
    # five of a kind    [5] - 1         -> 5 - 1 = 4
    # four of a kind    [4, 1]          -> 4 - 2 = 2
    # full house        [3, 2]          -> 3 - 2 = 1
    # three of a kind   [3, 1, 1]       -> 3 - 3 = 0
    # two pairs         [2, 2, 1]       -> 2 - 3 = -1
    # one pair          [2, 1, 1, 1]    -> 2 - 4 = -2
    # high card         [1, 1, 1, 1, 1] -> 1 - 5 = -4
    hd(a) - length(a)
  end

  def compare_hands(a, b), do: compare_hands(Enum.zip(a, b))
  def compare_hands([]), do: true

  def compare_hands([{a, b} | t]) do
    cond do
      a > b -> false
      a < b -> true
      true -> compare_hands(t)
    end
  end

  def stronger({_, hand_a, type_a}, {_, hand_b, type_b}) do
    cond do
      type_a > type_b -> false
      type_a < type_b -> true
      type_a == type_b -> compare_hands(hand_a, hand_b)
    end
  end

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [hand, bid] = String.split(line, " ")
      charl = hand |> to_charlist() |> Enum.map(&@card_values[&1])

      {String.to_integer(bid), charl, find_type(charl)}
    end)
  end

  def part1(args) do
    args
    |> parse()
    |> Enum.sort(&stronger/2)
    |> Enum.with_index(1)
    |> Enum.map(fn {{bid, _, _}, rank} -> bid * rank end)
    |> Enum.sum()
  end

  def part2(_args) do
    """
    32T3K 765
    T55J5 684
    KK677 28
    KTJJT 220
    QQQJA 483
    """
  end
end
