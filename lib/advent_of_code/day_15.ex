defmodule AdventOfCode.Day15 do
  import Enum

  @empty_box {[], MapSet.new()}
  def hash(item), do: hash(to_charlist(item), 0)
  def hash([], v), do: v
  def hash([?\n | t], v), do: hash(t, v)
  def hash([h | t], v), do: hash(t, rem((v + h) * 17, 256))

  def part1(args) do
    args
    |> String.split(",", trim: true)
    |> map(&hash/1)
    |> sum()
  end

  def parse_item(item) do
    if String.contains?(item, "=") do
      [k, v] = String.split(item, "=", trim: true)
      {:plus, k, hash(k), String.to_integer(v)}
    else
      h = String.replace(item, "-", "")
      {:minus, h, hash(h)}
    end
  end

  def parse(args), do: args |> String.split(",", trim: true) |> map(&parse_item/1)

  def replace_lens(lenses_list, label, v) do
    for {lab, _val} = p <- lenses_list do
      if lab == label,
        do: {label, v},
        else: p
    end
  end

  def execute({:minus, label, h}, boxes) do
    cond do
      not Map.has_key?(boxes, h) ->
        boxes

      label not in elem(boxes[h], 1) ->
        boxes

      true ->
        Map.update(boxes, h, @empty_box, fn {lenses_list, lenses_set} ->
          {reject(lenses_list, fn {lab, _} -> label == lab end), MapSet.delete(lenses_set, label)}
        end)
    end
  end

  def execute({:plus, label, h, v}, boxes) do
    cond do
      not Map.has_key?(boxes, h) ->
        Map.put(boxes, h, {[{label, v}], MapSet.new([label])})

      label not in elem(boxes[h], 1) ->
        Map.update(boxes, h, @empty_box, fn {lenses_list, lenses_set} ->
          {[{label, v} | lenses_list], MapSet.put(lenses_set, label)}
        end)

      true ->
        Map.update(boxes, h, @empty_box, fn {lenses_list, lenses_set} ->
          {replace_lens(lenses_list, label, v), lenses_set}
        end)
    end
  end

  def score(boxes) do
    boxes
    |> map(fn {b, {lenses_list, _}} ->
      lenses_list
      |> reverse()
      |> with_index(1)
      |> map(fn {{_l, v}, i} -> v * i * (b + 1) end)
      |> sum()
    end)
    |> sum()
  end

  def part2(args), do: args |> parse() |> reduce(%{}, &execute/2) |> score()
end
