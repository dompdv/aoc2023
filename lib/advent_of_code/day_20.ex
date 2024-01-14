defmodule AdventOfCode.Day20 do
  import Enum

  def parse_line("broadcaster -> " <> to),
    do: {:start, {:broadcaster, parse_list(to)}}

  def parse_line("%" <> l), do: parse_connector(l, :flipflop)
  def parse_line("&" <> l), do: parse_connector(l, :conj)

  def parse_list(to), do: to |> String.split(",", trim: true) |> map(&String.trim/1)

  def parse_connector(l, t) do
    [from, to] = String.split(l, "->", trim: true)
    {String.trim(from), {t, parse_list(to)}}
  end

  def parse(args), do: args |> String.split("\n", trim: true) |> map(&parse_line/1)

  def part1(args) do
    args |> test() |> parse()
  end

  def part2(_args) do
    :ok
  end

  def test(_) do
    """
    broadcaster -> a, b, c
    %a -> b
    %b -> c
    %c -> inv
    &inv -> a
    """
  end

  def test2(_) do
    """
    broadcaster -> a
    %a -> inv, con
    &inv -> b
    %b -> con
    &con -> output
    """
  end
end
