defmodule AdventOfCode.Day02 do
  import Enum

  @colors %{"red" => :red, "green" => :green, "blue" => :blue}

  # PARSING
  # Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
  # => [{1, [%{blue: 3, red: 4}, %{blue: 6, green: 2, red: 1}, %{green: 2}]}]

  # Parse one dive
  def parse_dive(hand) do
    [count, color] = hand |> String.split(" ", trim: true)
    {@colors[color], String.to_integer(count)}
  end

  # Parse one round
  def parse_round(round) do
    Map.merge(
      %{red: 0, green: 0, blue: 0},
      round
      |> String.split(",", trim: true)
      |> map(&parse_dive/1)
      |> Enum.into(%{})
    )
  end

  # Parse one game
  def parse_line(line) do
    ["Game " <> game, rounds] = line |> String.split(":", trim: true)
    {String.to_integer(game), rounds |> String.split(";", trim: true) |> Enum.map(&parse_round/1)}
  end

  # Parse each game
  def parse(input), do: input |> String.split("\n", trim: true) |> Enum.map(&parse_line/1)

  # Part 1
  def part1(args) do
    args
    |> parse()
    # Keep only the games where all dives have red <= 12, green <= 13, blue <= 14
    |> filter(fn {_, rounds} ->
      all?(rounds, fn round ->
        round[:red] <= 12 and round[:green] <= 13 and round[:blue] <= 14
      end)
    end)
    # keep the game id
    |> map(&elem(&1, 0))
    |> sum()
  end

  # Part 2
  # Compute the product of the maximum number of each color
  def compute_power({_game, rounds}) do
    for color <- [:red, :green, :blue] do
      rounds |> map(&Map.get(&1, color)) |> max()
    end
    |> product()
  end

  def part2(args), do: args |> parse() |> map(&compute_power/1) |> sum()
end
