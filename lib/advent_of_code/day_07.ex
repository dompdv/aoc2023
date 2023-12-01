defmodule AdventOfCode.Day07 do
  import Enum

  @complex ~r/(.+) \((\d+)\) -> (.*)/

  @simple ~r/(.+) \((\d+)\)/
  def parse(args), do: String.split(args, "\n", trim: true) |> map(&parse_line/1)

  def parse_line(line) do
    cond do
      Regex.match?(@complex, line) ->
        [_, d, w, l] = Regex.run(@complex, line)
        {d, String.to_integer(w), String.split(l, ",", trim: true) |> map(&String.trim/1)}

      Regex.match?(@simple, line) ->
        [_, d, w] = Regex.run(@simple, line)
        {d, String.to_integer(w), []}

      true ->
        raise "Parsing error"
    end
  end

  def build_tree(args) do
    reduce(
      args,
      %{},
      fn {d, _, l}, tree ->
        tree = if Map.get(tree, d, nil) == nil, do: Map.put(tree, d, nil), else: tree

        reduce(l, tree, fn d_local, tree_local ->
          Map.put(tree_local, d_local, d)
        end)
      end
    )
  end

  def part1(args) do
    build_tree(parse(args)) |> find(fn {_d, v} -> v == nil end) |> elem(0)
  end

  def reverse_tree(tree) do
    reduce(tree, %{}, fn {to, from}, r_tree ->
      Map.put(r_tree, from, [to | Map.get(r_tree, from, [])])
    end)
  end

  def samesame(l), do: count(uniq(l)) == 1

  def weight_of(node, tree, weights) do
    weights[node] +
      if Map.has_key?(tree, node),
        do: sum(for n <- tree[node], do: weight_of(n, tree, weights)),
        else: 0
  end

  def find_highest(imbalanced) do
    keys = for {n, _, _} <- imbalanced, do: n

    find(imbalanced, fn {_, l, _} ->
      {target, _} =
        frequencies(for {_, w} <- l, do: w)
        |> find(fn {_w, v} -> v != 1 end)

      {node_to_change, _current} = find(l, fn {_n, w} -> w != target end)
      node_to_change not in keys
    end)
  end

  def part2(args) do
    parsed = parse(args)
    weights = for {d, w, _} <- parsed, into: %{}, do: {d, w}
    tree = build_tree(parsed) |> reverse_tree()

    {_, imbalanced, _} =
      for {node, l} <- tree,
          node != nil do
        list_with_weights = for(n <- l, do: {n, weight_of(n, tree, weights)})

        {node, list_with_weights, samesame(for {_, w} <- list_with_weights, do: w)}
      end
      |> filter(fn {_node, _l, t} -> t == false end)
      |> find_highest()

    {target, _} =
      frequencies(for {_, w} <- imbalanced, do: w)
      |> find(fn {_w, v} -> v != 1 end)

    {node_to_change, current} = find(imbalanced, fn {_n, w} -> w != target end)

    target - current + weights[node_to_change]
  end
end
