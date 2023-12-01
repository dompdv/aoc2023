defmodule AdventOfCode.Day14 do
  @hexas for i <- 0..15,
             into: %{},
             do:
               {if(i <= 9, do: ?0 + i, else: i - 10 + ?A),
                Integer.to_string(i, 2) |> String.pad_leading(4, "0") |> String.to_charlist()}

  def convert_to_binary(hexa) do
    hexa
    |> String.to_charlist()
    |> Enum.map(&Map.get(@hexas, &1))
    |> List.flatten()
  end

  def part1(_args) do
    args = "xlqgujun"

    for i <- 0..127 do
      AdventOfCode.Day10.part2("#{args}-#{i}")
      |> convert_to_binary()
      |> Enum.count(fn c -> c == ?1 end)
    end
    |> Enum.sum()
  end

  def get_occupied_cells(hash_key) do
    # Create a MapSet of the coordinates (row, column) of the occupied cells

    for i <- 0..127 do
      # Compute hash
      AdventOfCode.Day10.part2("#{hash_key}-#{i}")
      |> convert_to_binary()
      # add column number
      |> Enum.with_index()
      # Keep only the 1s
      |> Enum.filter(fn {c, _} -> c == ?1 end)
      # Add row
      |> Enum.map(fn {_, index} -> {i, index} end)
    end
    |> List.flatten()
    |> MapSet.new()
  end

  def occupied_neighbours(graph, {row, col}) do
    [{row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}]
    |> Enum.filter(fn n -> MapSet.member?(graph, n) end)
  end

  # Maintien une liste de noeuds à visiter et une liste de noeuds visités
  def find_connex(_, [], visited), do: visited

  def find_connex(graph, [node | to_visit], visited) do
    # Si déjà visité, on passe au suivant
    if MapSet.member?(visited, node),
      do: find_connex(graph, to_visit, visited),
      # Sinon, on ajoute les voisins à visiter et on ajoute le noeud aux visités
      else:
        find_connex(
          graph,
          to_visit ++ occupied_neighbours(graph, node),
          MapSet.put(visited, node)
        )
  end

  def find_connex(graph, cell, visited), do: find_connex(graph, [cell], visited)

  def part2(_args) do
    args = "xlqgujun"
    disk_map = get_occupied_cells(args)

    disk_map
    |> Enum.reduce(
      # {nombre de groupes, liste des noeuds visités}
      {0, MapSet.new()},
      fn cell, {groups, visited} ->
        # si déjà visité, on passe au suivant
        if MapSet.member?(visited, cell),
          do: {groups, visited},
          # sinon, on incrémente le nombre de groupes et on ajoute les noeuds connexes aux visités
          else: {groups + 1, find_connex(disk_map, cell, visited)}
      end
    )
    |> elem(0)
  end
end
