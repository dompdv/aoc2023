defmodule AdventOfCode.Day22 do
  import Enum

  def to_structure([[x, y, z], [x, y, z]]), do: {z, 1, :z, [[x, y]]}
  def to_structure([[l, y, z], [h, y, z]]), do: {z, 1, :x, for(i <- l..h, do: [i, y])}
  def to_structure([[x, l, z], [x, h, z]]), do: {z, 1, :y, for(i <- l..h, do: [x, i])}
  def to_structure([[x, y, l], [x, y, h]]), do: {l, h - l + 1, :z, [[x, y]]}

  def intlist(l), do: l |> String.split(",", trim: true) |> map(&String.to_integer/1)
  def parse_line(line), do: String.split(line, "~") |> map(&intlist/1)

  def parse(args),
    do: args |> String.split("\n", trim: true) |> map(&parse_line/1)

  def prepare(cubes), do: cubes |> map(&to_structure/1)

  def field_size(cubes) do
    corners = cubes |> map(fn {_, l, _} -> zip(l) end)

    for dim <- 0..2 do
      corners |> map(fn c -> at(c, dim) |> Tuple.to_list() end) |> List.flatten() |> min_max()
    end
  end

  def sort_cubes(cubes), do: cubes |> Enum.sort_by(&elem(&1, 0))

  def height(elevation, x, y), do: Map.get(elevation, {x, y}, 0)

  def fall(sorted_cubes) do
    {_, fell, has_moved} =
      Enum.reduce(sorted_cubes, {%{}, [], 0}, fn cube, {elevations, cubes, moved} ->
        {l, h, t, xys} = cube
        highest = max(for([x, y] <- xys, do: height(elevations, x, y)))

        new_elevations =
          Enum.reduce(xys, elevations, fn [x, y], acc ->
            Map.put(acc, {x, y}, highest + h)
          end)

        if l == highest + 1,
          do: {new_elevations, [cube | cubes], moved},
          else: {new_elevations, [{highest + 1, h, t, xys} | cubes], moved + 1}
      end)

    {reverse(fell), has_moved}
  end

  def something_will_move(sorted_cubes) do
    will_move =
      Enum.reduce_while(sorted_cubes, %{}, fn cube, elevations ->
        {l, h, _t, xys} = cube
        highest = max(for([x, y] <- xys, do: height(elevations, x, y)))

        if l == highest + 1 do
          {:cont,
           Enum.reduce(xys, elevations, fn [x, y], acc ->
             Map.put(acc, {x, y}, highest + h)
           end)}
        else
          {:halt, :move}
        end
      end)

    will_move == :move
  end

  def can_desintegrate(i, fell),
    do: fell |> List.delete_at(i) |> something_will_move() |> then(&(not &1))

  def part1(args) do
    fell = args |> parse() |> prepare() |> sort_cubes() |> fall() |> elem(0)

    for(i <- 0..(length(fell) - 1), can_desintegrate(i, fell), do: 1) |> sum()
  end

  def part2(args) do
    fell = args |> parse() |> prepare() |> sort_cubes() |> fall() |> elem(0)

    for i <- 0..(length(fell) - 1) do
      fell |> List.delete_at(i) |> fall() |> elem(1)
    end
    |> sum()
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
