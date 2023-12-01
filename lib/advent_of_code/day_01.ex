defmodule AdventOfCode.Day01 do
  import Enum

  @numbers ([{"eightwo", [8, 2]}]
            |> map(fn {s, l} -> {to_charlist(s), l} end)) ++
             ([
                "one",
                "two",
                "three",
                "four",
                "five",
                "six",
                "seven",
                "eight",
                "nine"
              ]
              |> with_index()
              |> map(fn {s, i} -> {to_charlist(s), i + 1} end))

  def process_p1(x) do
    x
    |> String.replace(~r/[^0-9]/, "")
    |> to_charlist()
    |> then(fn x -> (hd(x) - ?0) * 10 + (List.last(x) - ?0) end)
  end

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> map(&process_p1/1)
    |> sum()
  end

  def compute_number([x]), do: x * 11
  def compute_number([x | r]), do: x * 10 + List.last(r)

  def process_string([], acc), do: reverse(acc)

  def process_string(s, acc) do
    case filter(@numbers, fn {k, _} -> List.starts_with?(s, k) end) do
      [] ->
        if hd(s) in ?0..?9,
          do: process_string(drop(s, 1), [hd(s) - ?0 | acc]),
          else: process_string(drop(s, 1), acc)

      [{number_s, n} | _] when is_list(n) ->
        process_string(drop(s, length(number_s)), reverse(n) ++ acc)

      [{number_s, n} | _] ->
        process_string(drop(s, length(number_s)), [n | acc])
    end
  end

  def process_string(s) do
    s
    |> String.trim()
    |> to_charlist()
    |> process_string([])
    |> compute_number()
  end

  def part2(args),
    do:
      args
      |> String.split("\n", trim: true)
      |> map(&process_string/1)
      |> sum()

  def numbers(), do: @numbers
end
