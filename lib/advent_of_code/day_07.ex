defmodule AdventOfCode.Day07 do
  # Map cards to their values
  @card_values for(c <- ?2..?9, into: %{}, do: {c, c - ?0})
               |> Map.merge(%{?T => 10, ?J => 11, ?Q => 12, ?K => 13, ?A => 14})

  # Jokers are 1, which is the lowest value
  @card_values2 Map.put(@card_values, ?J, 1)

  # List comparison in Elixir is lexicographical
  def stronger({_, hand_a, type_a}, {_, hand_b, type_a}), do: hand_a < hand_b
  def stronger({_, _, type_a}, {_, _, type_b}), do: type_a < type_b

  # List of tuples, where the first element is the bid and the second is the hand
  def parse(input, card_values) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [hand, bid] = String.split(line, " ")
      # Keep oonly the values of the cards
      {String.to_integer(bid), hand |> to_charlist() |> Enum.map(&card_values[&1])}
    end)
  end

  # Assign a number to each hand type, so that we can compare them
  def find_type1(charl) do
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

  # no jokers
  def add_jokers(freq, nil), do: freq
  # 5 jokers
  def add_jokers(freq, 5), do: freq

  # 1 to 4 jokers
  def add_jokers(freq, jokers) do
    freq = freq |> Map.delete(1)
    # find the most frequent card
    key_max = Enum.max_by(freq, fn {_, v} -> v end) |> elem(0)
    # add the jokers to the most frequent card
    Map.update(freq, key_max, 1, &(&1 + jokers))
  end

  def find_type2(charl) do
    freq = charl |> Enum.frequencies()
    # freq[1] is the number of jokers
    freq_list =
      freq
      # add the jokers to the most frequent card
      |> add_jokers(freq[1])
      |> Map.values()
      |> Enum.sort(:desc)

    hd(freq_list) - length(freq_list)
  end

  def process(args, card_values, find_type_function) do
    args
    |> parse(card_values)
    # Add the type value to the tuple
    |> Enum.map(fn {bid, charl} -> {bid, charl, find_type_function.(charl)} end)
    # Sort by type, then by hand
    |> Enum.sort(&stronger/2)
    # Add the rank to the tuple
    |> Enum.with_index(1)
    # Multiply the bid by the rank and sum
    |> Enum.map(fn {{bid, _, _}, rank} -> bid * rank end)
    |> Enum.sum()
  end

  def part1(args), do: process(args, @card_values, &find_type1/1)

  def part2(args), do: process(args, @card_values2, &find_type2/1)
end
