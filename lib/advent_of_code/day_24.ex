defmodule AdventOfCode.Day24 do
  def parse_line(line) do
    Regex.scan(~r/-?\d+/, line)
    |> List.flatten()
    |> Enum.map(&String.to_integer/1)
    |> Enum.split(3)
  end

  def parse(args), do: args |> String.split("\n", trim: true) |> Enum.map(&parse_line/1)

  #### PART 1 ####
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

  #### PART 2 ####

  def system_eq(p, v, t, hs) do
    # t = [t1,t2,t3], hs = [{[x1,y1,z1],[vx1,vy1,vz1]},{[x2,y2,z2],[vx2,vy2,vz2]}, {[x3,y3,z3],[vx3,vy3,vz3]}]
    [x, y, z] = p
    [vx, vy, vz] = v

    for {ti, {[xi, yi, zi], [vxi, vyi, vzi]}} <- Enum.zip(t, hs) do
      [
        x + ti * vx - (xi + ti * vxi),
        y + ti * vy - (yi + ti * vyi),
        z + ti * vz - (zi + ti * vzi)
      ]
    end
    |> List.flatten()

    #    |> Enum.reduce(0, fn x, acc -> acc + x * x end)
    #    |> :math.sqrt()
  end

  def build_f(points) do
    fn [x, y, z, vx, vy, vz, t1, t2, t3] ->
      system_eq([x, y, z], [vx, vy, vz], [t1, t2, t3], points)
    end
  end

  def f(x, points) do
  end

  # Solving an equation f(X) = 0 with Newton's approach
  # where X is a vector and f a function
  def solve_newton(
        [_x, _y, _z, vx, vy, vz, t1, t2, t3] = x0,
        f,
        [{_, [vx1, vy1, vz1]}, {_, [vx2, vy2, vz2]}, {_, [vx3, vy3, vz3]}] = points,
        eps
      ) do
    v0 = f.(x0)
    v0nx = Nx.tensor(v0, type: {:f, 64})

    # jacobian matrix
    sub =
      [
        [1, 0, 0, t1, 0, 0, vx - vx1, 0, 0],
        [0, 1, 0, 0, t1, 0, vy - vy1, 0, 0],
        [0, 0, 1, 0, 0, t1, vz - vz1, 0, 0],
        [1, 0, 0, t2, 0, 0, 0, vx - vx2, 0],
        [0, 1, 0, 0, t2, 0, 0, vy - vy2, 0],
        [0, 0, 1, 0, 0, t2, 0, vz - vz2, 0],
        [1, 0, 0, t3, 0, 0, 0, 0, vx - vx3],
        [0, 1, 0, 0, t3, 0, 0, 0, vy - vy3],
        [0, 0, 1, 0, 0, t3, 0, 0, vz - vz3]
      ]
      |> Nx.tensor(type: {:f, 64})
      |> Nx.LinAlg.invert()
      |> Nx.dot(v0nx)

    x1 = Nx.tensor(x0, type: {:f, 64}) |> Nx.subtract(sub) |> Nx.to_list()

    norm =
      f.(x1) |> Nx.tensor() |> Nx.LinAlg.norm() |> Nx.to_number()

    if norm < eps do
      x1
    else
      solve_newton(x1, f, points, eps)
    end
  end

  def max_item(a, b), do: Enum.zip(a, b) |> Enum.map(fn {x, y} -> max(abs(x), abs(y)) end)

  def part2(args) do
    hs = args |> parse()

    three =
      Stream.repeatedly(fn -> Enum.take(Enum.shuffle(hs), 3) end)
      |> Stream.filter(fn x ->
        x |> Enum.map(&elem(&1, 1)) |> Nx.tensor() |> Nx.LinAlg.determinant() |> Nx.to_number() !=
          0
      end)
      |> Enum.take(1)
      |> List.flatten()

    #      |> IO.inspect(label: "three")

    starting_point =
      three
      |> Enum.map(fn {[x, y, z], [vx, vy, vz]} -> [x, y, z, vx, vy, vz, 1, 2, 3] end)
      |> Enum.reduce(&max_item/2)
      |> Enum.map(&(&1 / 3))

    [x, y, z, vx, vy, vz, _, _, _] = starting_point
    homo = Enum.max([abs(x), abs(y), abs(z)]) / 100_000
    homot = Enum.max([abs(vx), abs(vy), abs(vz)]) / 10

    updated_three =
      three
      |> Enum.map(fn {[tx, ty, tz], [tvx, tvy, tvz]} ->
        {[(tx - x) / homo, (ty - y) / homo, (tz - z) / homo],
         [tvx / homot, tvy / homot, tvz / homot]}
      end)

    updated_starting_point = [0, 0, 0, vx / homot, vy / homot, vz / homot, 2, 3, 7]

    f = build_f(updated_three)

    [xf, yf, zf | _] = solve_newton(updated_starting_point, f, three, 0.00001)

    [xf * homo + x, yf * homo + y, zf * homo + z]
    |> Enum.map(&round/1)
    |> Enum.sum()
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
