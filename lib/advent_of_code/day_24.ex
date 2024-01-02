defmodule AdventOfCode.Day24 do
  def parse_line(line) do
    Regex.scan(~r/-?\d+/, line)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> Enum.split(3)
  end

  def parse(args), do: args |> String.split("\n", trim: true) |> Enum.map(&parse_line/1)

  # Determinant of a 2*2 matrix
  def det([[a, b], [c, d]]), do: a * d - b * c

  def intersection_2d([x1, y1], [vx1, vy1], [x2, y2], [vx2, vy2]) do
    d = det([[vx1, vy1], [vx2, vy2]])

    if d == 0 do
      # parallel
      nil
    else
      t1 = det([[x2 - x1, vx2], [y2 - y1, vy2]]) / d
      t2 = det([[x2 - x1, vx1], [y2 - y1, vy1]]) / d
      # not in the past
      if t1 >= 0 and t2 >= 0,
        do: [x1 + vx1 * t1, y1 + vy1 * t1],
        else: nil
    end
  end

  def part1(args) do
    hs = args |> parse()
    {vmin, vmax} = {200_000_000_000_000, 400_000_000_000_000}

    wi =
      hs
      # Keep only x & y
      |> Enum.map(fn {[x1, y1, _], [vx1, vy1, _]} -> [x1, y1, vx1, vy1] end)
      |> Enum.with_index()

    # Find all intersections (once per pair of wires)
    for {[x1, y1, vx1, vy1], i} <- wi, {[x2, y2, vx2, vy2], j} <- wi, j > i do
      intersection_2d([x1, y1], [vx1, vy1], [x2, y2], [vx2, vy2])
    end
    |> Enum.reject(&(&1 == nil))
    # Keep only those in the square
    |> Enum.filter(fn [x, y] -> x >= vmin and x <= vmax and (y >= vmin and y <= vmax) end)
    |> Enum.count()
  end

  def part2(_args) do
    :ok
  end

  def test(_) do
    """
    19, 13, 30 @ -2,  1, -2
    18, 19, 22 @ -1, -1, -2
    20, 25, 34 @ -2, -2, -4
    12, 31, 28 @ -1, -2, -1
    20, 19, 15 @  1, -5, -3
    """
  end
end
