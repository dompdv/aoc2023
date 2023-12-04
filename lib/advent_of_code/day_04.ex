defmodule AdventOfCode.Day04 do
  import Enum

  # returns a set from a string like "1 2 3"
  def parse_l(l) do
    l
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> MapSet.new()
  end

  # returns a list  [ {card_id, {number_of_matches, card_score}}]
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      # fetch the card_id
      ["Card " <> n, r] = line |> String.trim() |> String.split(": ")

      # parse the two sets and count the interesections
      matches =
        r |> String.split("|") |> map(&parse_l/1) |> reduce(&MapSet.intersection/2) |> count()

      # compute score
      score = if matches == 0, do: 0, else: :math.pow(2, matches - 1) |> round()
      {String.to_integer(String.trim(n)), {matches, score}}
    end)
  end

  # Part 1
  def part1(args) do
    args
    |> parse_input()
    # everything has been done in the parsing, so we just need to sum the scores
    |> map(fn {_n, {_matches, score}} -> score end)
    |> sum()
  end

  # Play the whole game. to_scratch is the list of cards to scratch, deck is a Map of the initial deck, to create copies.
  # Acc is the total number of cards scratched (original + copies). We start by adding the original cards
  def play(to_scratch, deck), do: play(to_scratch, deck, length(to_scratch))

  # When there are no more cards to scratch, we return the total number of cards scratched
  def play([], _initial_deck, acc), do: acc

  # Scratch one card
  def play([card | rest], deck, acc) do
    {n, {matches, score}} = card

    # if there are no matches, we just continue
    if matches == 0 do
      play(rest, deck, acc)
    else
      # otherwise, we add the following n cards (n = matches) to the list of remaining cards to scratch and we count the number of cards added
      {to_scrach, total_added} =
        reduce((n + 1)..(n + matches), {rest, 0}, fn i, {e_rest, added} = same ->
          # don't add inexistent cards
          if Map.has_key?(deck, i),
            do: {[{i, deck[i]} | e_rest], added + 1},
            else: same
        end)

      # process the rest of the cards
      play(to_scrach, deck, acc + total_added)
    end
  end

  # Part 2
  def part2(args) do
    deck = parse_input(args)
    play(deck, Map.new(deck))
  end
end
