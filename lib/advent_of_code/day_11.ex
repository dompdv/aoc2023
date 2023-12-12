defmodule AdventOfCode.Day11 do
  import Enum

  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> with_index()
    |> map(fn {line, r} ->
      line
      |> to_charlist()
      |> with_index()
      |> map(fn {cell, c} -> {{r, c}, cell} end)
    end)
    |> List.flatten()
    |> filter(fn {_, cell} -> cell == ?# end)
    |> map(&elem(&1, 0))
  end

  # expansion is the number of rows/columns to add for empty lines/columns
  def post_process(stars, expansion) do
    rows = stars |> map(fn {r, _} -> r end)
    columns = stars |> map(fn {_, c} -> c end)
    {minr, maxr} = min_max(rows)
    {minc, maxc} = min_max(columns)

    # Create a mapping row => adjusted row number
    row_adjustment =
      reduce(minr..maxr, {0, []}, fn r, {last_row_number, new_mapping} ->
        if count(filter(stars, fn {crow, _} -> crow == r end)) == 0,
          do: {last_row_number + expansion, new_mapping},
          else: {last_row_number + 1, [{r, last_row_number} | new_mapping]}
      end)
      |> elem(1)
      |> Map.new()

    # same with columns
    column_adjustment =
      reduce(minc..maxc, {0, []}, fn c, {last_column_number, new_mapping} ->
        if count(filter(stars, fn {_, ccol} -> ccol == c end)) == 0,
          do: {last_column_number + expansion, new_mapping},
          else: {last_column_number + 1, [{c, last_column_number} | new_mapping]}
      end)
      |> elem(1)
      |> Map.new()

    {stars, row_adjustment, column_adjustment}
  end

  def compute_ditances({stars, row_adjustment, column_adjustment}) do
    indexed_stars = stars |> with_index()

    # Consider all distinct pairs of stars
    for {{r1, c1}, i1} <- indexed_stars, {{r2, c2}, i2} <- indexed_stars, i1 < i2 do
      # Manhattan distance between the two stars
      abs(row_adjustment[r1] - row_adjustment[r2]) +
        abs(column_adjustment[c1] - column_adjustment[c2])
    end
    |> sum()
  end

  def part1(args), do: args |> parse() |> post_process(2) |> compute_ditances()
  def part2(args), do: args |> parse() |> post_process(1_000_000) |> compute_ditances()
end
