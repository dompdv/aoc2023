defmodule AdventOfCode.Day11 do
  # Utilise les coordonnées cubiques (je dois avouer que j'ai trouvé un site très bien fait qui explique tout ça)
  def move("nw", {q, r, s}), do: {q, r - 1, s + 1}
  def move("n", {q, r, s}), do: {q + 1, r - 1, s}
  def move("ne", {q, r, s}), do: {q + 1, r, s - 1}
  def move("sw", {q, r, s}), do: {q - 1, r, s + 1}
  def move("s", {q, r, s}), do: {q - 1, r + 1, s}
  def move("se", {q, r, s}), do: {q, r + 1, s - 1}

  def dist({q, r, s}), do: div(abs(q) + abs(r) + abs(s), 2)

  def part1(args) do
    args
    # On split la chaîne en une liste de directions
    |> String.trim()
    |> String.split(",", trim: true)
    # On applique la fonction move à chaque direction
    |> Enum.reduce({0, 0, 0}, &move/2)
    # On calcule la distance à l'arrivée
    |> dist()
  end

  def part2(args) do
    args
    # On split la chaîne en une liste de directions
    |> String.trim()
    |> String.split(",", trim: true)
    # On applique la fonction move à chaque direction, en gardant le max atteint jusqu'à présent
    |> Enum.reduce(
      {0, {0, 0, 0}},
      fn direction, {max_so_far, position} ->
        new_position = move(direction, position)
        {max(max_so_far, dist(new_position)), new_position}
      end
    )
    |> elem(0)
  end
end
