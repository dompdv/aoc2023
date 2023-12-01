defmodule AdventOfCode.Day01 do
  import Enum

  # text representation of numbers, with their corresponding value
  @numbers [
             {"one", 1},
             {"two", 2},
             {"three", 3},
             {"four", 4},
             {"five", 5},
             {"six", 6},
             {"seven", 7},
             {"eight", 8},
             {"nine", 9}
           ]
           |> map(fn {s, l} -> {to_charlist(s), l} end)

  # Part 1 : process one line
  def process_p1(x) do
    # remove all non-digit characters
    x
    |> String.replace(~r/[^0-9]/, "")
    |> to_charlist()
    # compute the value from first and last digits of the list
    |> then(fn l -> (hd(l) - ?0) * 10 + (List.last(l) - ?0) end)
  end

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    # process each line
    |> map(&process_p1/1)
    # sum the values
    |> sum()
  end

  # Part 2

  # compute the number from a list of digits (using first and last digits). When there is one digit, it is multiplied by (10 x + x)
  def compute_number([x]), do: x * 11
  def compute_number([x | r]), do: x * 10 + List.last(r)

  # process one line: scan each character of the string, and build a list of digits
  def process_string([], acc), do: reverse(acc)

  def process_string([c | rest] = s, acc) do
    # check if one of the numbers is a prefix of the string
    case filter(@numbers, fn {k, _} -> List.starts_with?(s, k) end) do
      [] ->
        # if not, check if the character is a digit. If so, add it to the list, if not, ignore it. And go to the next character
        if c in ?0..?9,
          do: process_string(rest, [c - ?0 | acc]),
          else: process_string(rest, acc)

      # if yes, add the corresponding value to the list, and go to the next character
      [{_, n} | _] ->
        process_string(rest, [n | acc])
    end
  end

  # process one line: trim the string, convert it to a charlist, and call the recursive function, then compute the number
  def process_string(s) do
    s
    |> String.trim()
    |> to_charlist()
    |> process_string([])
    |> compute_number()
  end

  # process each line, and sum the values
  def part2(args) do
    args
    |> String.split("\n", trim: true)
    |> map(&process_string/1)
    |> sum()
  end
end
