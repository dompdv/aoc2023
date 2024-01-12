defmodule AdventOfCode.Day22 do
  import Enum

  def add_type([[x, y, z], [x, y, z]] = c), do: {:unit, c, [[x, y, z]]}
  def add_type([[l, y, z], [h, y, z]] = c), do: {:x, c, for(i <- l..h, do: [i, y, z])}
  def add_type([[x, l, z], [x, h, z]] = c), do: {:y, c, for(i <- l..h, do: [x, i, z])}
  def add_type([[x, y, l], [x, y, h]] = c), do: {:z, c, for(i <- l..h, do: [x, y, i])}

  def intlist(l), do: l |> String.split(",", trim: true) |> map(&String.to_integer/1)
  def parse_line(line), do: String.split(line, "~") |> map(&intlist/1)

  def parse(args),
    do: args |> String.split("\n", trim: true) |> map(&parse_line/1) |> map(&add_type/1)

  def add_field_size(cubes) do
    corners = cubes |> map(fn {_, l, _} -> zip(l) end)

    max_min_per_dim =
      for dim <- 0..2 do
        corners |> map(fn c -> at(c, dim) |> Tuple.to_list() end) |> List.flatten() |> min_max()
      end

    {max_min_per_dim, cubes}
  end

  def part1(args) do
    {max_min_per_dim, cubes} = args |> test() |> parse() |> add_field_size()
    # {max_min_per_dim, cubes} = args |> parse() |> add_field_size()
    reduce(cubes, 0, fn {_, _, l}, acc -> acc + length(l) end)
  end

  def part2(_args) do
    :ok
  end

  def test(_) do
    """
    1,0,1~1,2,1
    0,0,2~2,0,2
    0,2,3~2,2,3
    0,0,4~0,2,4
    2,0,5~2,2,5
    0,1,6~2,1,6
    1,1,8~1,1,9
    """
  end
end
