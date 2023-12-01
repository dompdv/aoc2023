defmodule AdventOfCode.Day16 do
  def string_to_integer(s), do: (s |> String.first() |> to_charlist() |> hd()) - ?a

  def parse_input(input) do
    input
    |> String.trim()
    |> String.split(",", trim: true)
    |> Enum.map(fn x ->
      case String.trim(x) do
        "s" <> n ->
          {:spin, String.to_integer(n)}

        "x" <> e ->
          [a, b] = String.split(e, "/")
          {:exchange, String.to_integer(a), String.to_integer(b)}

        "p" <> p ->
          [a, b] = String.split(p, "/")
          {:partner, string_to_integer(a), string_to_integer(b)}
      end
    end)
  end

  def print_s(mapping) do
    reverse = for {i, j} <- mapping, into: %{}, do: {j, i}
    maps = for(i <- 0..(map_size(mapping) - 1), do: reverse[i] + ?a) |> to_string()
    IO.puts("Mapping: #{maps}")
    mapping
  end

  def inital_state(n), do: for(i <- 0..(n - 1), into: %{}, do: {i, i})

  def next_state({:spin, x}, mapping) do
    n = map_size(mapping)
    for {i, j} <- mapping, into: %{}, do: if(j < n - x, do: {i, j + x}, else: {i, j - n + x})
  end

  def next_state({:exchange, a, b}, mapping) do
    for {i, j} <- mapping do
      cond do
        j == a -> {i, b}
        j == b -> {i, a}
        true -> {i, j}
      end
    end
    |> Map.new()
  end

  def next_state({:partner, a, b}, mapping) do
    mapping |> Map.put(a, mapping[b]) |> Map.put(b, mapping[a])
  end

  def one_dance(steps, starting_point), do: Enum.reduce(steps, starting_point, &next_state/2)

  def part1(args) do
    n_dancers = 16

    args
    |> parse_input()
    |> one_dance(inital_state(n_dancers))
    |> print_s()

    :ok
  end

  def apply_permutation(mapping, permutation) do
    for {i, j} <- mapping, into: %{}, do: {i, permutation[j]}
  end

  # find smallest common multiple of a list of integers
  def gcd(a, 0), do: abs(a)
  def gcd(a, b), do: gcd(b, rem(a, b))

  def lcm(a, b), do: div(abs(a * b), gcd(a, b))
  def lcm(l), do: Enum.reduce(l, 1, &lcm/2)

  # Find a cycle in a permutation starting from s
  def find_cycle(permutation, s, cycle) do
    ps = permutation[s]
    if ps in cycle, do: cycle, else: find_cycle(permutation, ps, [ps | cycle])
  end

  # Decompose a permutation into cycles
  def decomp_perm(_permutation, [], cycles), do: cycles

  def decomp_perm(permutation, [s | to_visit], cycles) do
    cycle = find_cycle(permutation, s, [s])
    decomp_perm(permutation, to_visit -- cycle, [cycle | cycles])
  end

  # Find the number of iterations to go back to the initial state
  # It's the PPCM of the lengths of the cycles
  def decomp_perm(permutation),
    do: decomp_perm(permutation, Map.values(permutation), []) |> Enum.map(&Enum.count/1) |> lcm()

  def part2(args) do
    #    args = "s1,x3/4,pe/b"
    #    args = List.duplicate("s1", 4) |> Enum.join(",")
    n_dancers = 16
    initial_order = inital_state(n_dancers)

    permutation =
      args
      |> parse_input()
      |> one_dance(initial_order)

    loop_size =
      decomp_perm(permutation)
      |> IO.inspect(label: "cycles")

    Enum.reduce(
      1..rem(1_000_000_000, loop_size),
      initial_order |> print_s(),
      fn i, state ->
        IO.inspect(i)
        apply_permutation(state, permutation) |> print_s()
      end
    )
    |> print_s()

    :ok
  end
end
