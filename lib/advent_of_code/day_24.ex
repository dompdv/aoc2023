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

  # Find all divisors of a number
  def divisors(n) do
    n = abs(n)
    nn = :math.sqrt(n) |> round()

    divisors =
      Enum.reduce(1..nn, [], fn i, acc ->
        if rem(n, i) == 0 do
          d = div(n, i)

          if d != i,
            do: [d, i | acc],
            else: [i | acc]
        else
          acc
        end
      end)

    divisors ++ Enum.map(divisors, &(&1 * -1))
  end

  # La GROSSE astuce
  def find_candidates({vx1, l}, dim) do
    wi = Enum.with_index(l)

    # On considère tous les couples de 2 grêlons qui ont le même vx (par exemple, pour dim==0)
    # "x + t1 * vx = x1 + t1 * vx1" et "x + t2 * vx = x2 + t2 * vx2" avec vx1 = vx2 donne
    # "x2-x1 = (t2-t1)(vx-vx1)"
    # Comme ce sont des équations entières, cela veut dire que (vx-vx1) est un diviseur (positif ou négatif) de x2-x1
    # Donc vx est dans l'ensemble vx1+d quand d parcourt tous les diviseurs
    for {p1, i} <- wi, {p2, j} <- wi, i < j do
      x1 = p1 |> elem(0) |> Enum.at(dim)
      x2 = p2 |> elem(0) |> Enum.at(dim)
      x2_x1 = x2 - x1
      # Trouvons les diviseurs de x2-x1 et déduisons les vx possibles
      for(vx_vx1 <- divisors(x2_x1), do: vx_vx1 + vx1) |> MapSet.new()
    end
    # Prendre l'intersection sur tous les couples pour ce vx1 fixé
    |> Enum.reduce(fn a, acc -> MapSet.intersection(a, acc) end)
  end

  # Converge vers le vecteur vitesse sur la dimension 0..2 (c'est à dire x,y ou z)
  def find_v(velocities, dim) do
    # On va prendre tous les couples de vecteurs ayant le même vx (pour dim = 0, vy pour dim= 1 etc)
    # Pour chaque couple, on a un ensemble de vx (resp vy et vz) possibles (voir find_candidates)
    # On va faire l'intersection des ensembles jusqu'à arriver sur un singleton
    velocities[dim]
    |> Enum.reduce_while(MapSet.new(), fn vs, acc ->
      c = find_candidates(vs, dim)
      i = MapSet.intersection(acc, c)

      cond do
        # Premier pas
        MapSet.size(acc) == 0 -> {:cont, c}
        # Arrêt si singleton
        MapSet.size(i) == 1 -> {:halt, i}
        # Intersections successives
        true -> {:cont, i}
      end
    end)
    # Prendre un élément (qui doit être unique de toutes façons)
    |> MapSet.to_list()
    |> hd()
  end

  # Solve a linear 2X2 system of Integer parameters
  # In the case of the problem, the divisions are exact
  def solve_sys2([[a, b], [c, d]], [alpha, beta]) do
    det = a * d - c * b
    [div(d * alpha - b * beta, det), div(a * beta - c * alpha, det)]
  end

  def part2(args) do
    hs = args |> parse()

    # Trouver les couples de grêlon qui ont la même coordonnée de vitesse
    # par exemple le même vx. (faire de même pour les vy et vz)
    same_velocities =
      for i <- 0..2, into: %{} do
        {i,
         Enum.group_by(hs, fn {_, c} -> Enum.at(c, i) end)
         |> Enum.reject(fn {_, v} -> Enum.count(v) == 1 end)}
      end

    # Converge vers le vecteur vitesse
    [vx, vy, vz] = for dim <- 0..2, do: find_v(same_velocities, dim)
    # Quand on a le vecteur vitesse, on peut trouver les t1 et t2 (les deux temps d'impact)
    # sur deux grêlons pris au hasard
    [{[x1, y1, z1], [vx1, vy1, vz1]}, {[x2, y2, _], [vx2, vy2, _]}] =
      hs |> Enum.shuffle() |> Enum.take(2)

    # On élimine x dans  "x + t1 * vx = x1 + t1 * vx1" et "x + t2 * vx = x2 + t2 * vx2" pour trouver une équation en t1 et t2
    # idem pour     y + t1 * vy = y1 + t1 * vy1 et y + t2 * vy = y2 + t2 * vy2
    # Ce qui permet d'avoir un système linéaire 2x2
    [t1, _t2] = solve_sys2([[vx1 - vx, vx - vx2], [vy1 - vy, vy - vy2]], [x2 - x1, y2 - y1])
    # une fois t1 et t2 trouvés, on peut en déduire les x,y & z
    [x1 + t1 * (vx1 - vx), y1 + t1 * (vy1 - vy), z1 + t1 * (vz1 - vz)] |> Enum.sum()
  end
end
