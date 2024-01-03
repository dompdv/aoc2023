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

  # Solving an equation f(X) = 0 with Newton's approach
  # where X is a vector and f a function
  def solve_newton(x0, f, eps) do
    h = 0.00001
    v0 = f.(x0)
    v0nx = Nx.tensor(v0, type: {:f, 32})
    x0wi = Enum.with_index(x0)

    jacob =
      for {c, i} <- x0wi do
        x1 = for {c2, j} <- x0wi, do: if(i == j, do: c + h, else: c2)
        for {c1, c0} <- Enum.zip(f.(x1), v0), do: (c1 - c0) / h
      end
      |> Nx.tensor()

    sub =
      jacob
      |> Nx.transpose()
      |> Nx.LinAlg.invert()
      |> Nx.dot(v0nx)
      |> dbg()

    x1 = Nx.subtract(v0nx, sub) |> IO.inspect()

    if Nx.abs(x1) |> Nx.sum() < eps do
      Nx.to_list(x1)
    else
      solve_newton(Nx.to_list(x1), f, eps)
    end
  end

  def part2(args) do
    hs = args |> test() |> parse()

    three =
      Stream.repeatedly(fn -> Enum.take(Enum.shuffle(hs), 3) end)
      |> Stream.filter(fn x ->
        x |> Enum.map(&elem(&1, 1)) |> Nx.tensor() |> Nx.LinAlg.determinant() |> Nx.to_number() !=
          0
      end)
      |> Enum.take(1)
      |> List.flatten()

    f = build_f(three)
    #    system_eq([1000, 1000, 1000], [1, 1, 1], [1, 2, 3], three)
    solve_newton([25, 13, 12, -4, 1, 2, 1, 2, 3], f, 0.00001)

    #   three |> Enum.map(&elem(&1, 1)) |> Nx.tensor() |> Nx.LinAlg.determinant() |> Nx.to_number()
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
