defmodule AdventOfCode.Day20 do
  import Enum

  # Basic parsing
  def parse_line("broadcaster -> " <> to),
    do: {:broadcaster, {:broadcaster, parse_list(to)}}

  def parse_line("%" <> l), do: parse_connector(l, :flipflop)
  def parse_line("&" <> l), do: parse_connector(l, :conj)

  def parse_list(to),
    do: to |> String.split(",", trim: true) |> map(&String.trim/1) |> map(&String.to_atom/1)

  def parse_connector(l, t) do
    [from, to] = String.split(l, "->", trim: true)
    {from |> String.trim() |> String.to_atom(), {t, parse_list(to)}}
  end

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> map(&parse_line/1)
    |> then(fn l -> [{:button, {:button, [:broadcaster]}} | l] end)
    |> into(%{})
  end

  # Find predecessors
  def find_predecessors(graph) do
    # Loop through the graph, and for each node
    reduce(
      graph,
      # map %{node => [predecessors]}
      %{},
      fn {k, {_, l}}, acc ->
        # Loop through the list of successors and update the predecessors map
        reduce(l, acc, fn e, p ->
          current = Map.get(p, e, [])
          Map.put(p, e, [k | current])
        end)
      end
    )
  end

  def inital_state(graph) do
    predecessors = find_predecessors(graph)

    for {k, {t, _l}} <- graph do
      {k,
       case t do
         :button -> nil
         :broadcaster -> nil
         :flipflop -> :off
         :conj -> for p <- predecessors[k], into: %{}, do: {p, :low}
       end}
    end
    |> Map.new()
  end

  def inc_low(counter, n \\ 1), do: %{counter | low: n + counter[:low]}
  def inc_high(counter, n \\ 1), do: %{counter | high: n + counter[:high]}
  def inc_signal(counter, signal, n \\ 1), do: %{counter | signal => n + counter[signal]}

  # Flip the state of a flipflop
  def flip(:on), do: :off
  def flip(:off), do: :on
  def flip(state, node), do: Map.put(state, node, flip(state[node]))

  # Send a signal to all successors
  def broadcast(signal, from, successors), do: for(to <- successors, do: {from, to, signal})

  def all_high?(l), do: all?(Map.values(l), &(&1 == :high))
  # Execute one hop of the signal
  # ie process one pulse
  # A pulse is a tuple {to_node, signal, from_node}
  # Returns a tuple {new_pulses, new_state, new_counter}
  def hop({from_node, to_node, signal}, state, counter, graph) do
    #    IO.inspect({from_node, to_node, signal, state, counter}, label: "Hop")
    node_state = state[to_node]
    {node_type, successors} = Map.get(graph, to_node, {nil, nil})
    ns = if successors == nil, do: 0, else: length(successors)

    cond do
      # button, send a low signal to :broadcaster and increment the low counter
      node_type == :button ->
        {[{:button, :broadcaster, :low}], state, inc_low(counter)}

      # broadcaster, transmit the signal to all successors and increment the signal counter
      node_type == :broadcaster ->
        {broadcast(signal, to_node, successors), state, inc_signal(counter, signal, ns)}

      # end node, stop the signal
      node_state == nil ->
        {[], state, counter}

      # flipflop receiving a high signal: do nothing
      node_type == :flipflop and signal == :high ->
        {[], state, counter}

      # flipflop receiving a low signal: send a high signal if flipflop on off, a low if flipflop on on, and flip the flipflop
      node_type == :flipflop ->
        signal_to_send = if node_state == :off, do: :high, else: :low

        {broadcast(signal_to_send, to_node, successors), flip(state, to_node),
         inc_signal(counter, signal_to_send, ns)}

      # conj
      node_type == :conj ->
        # update node memory
        new_node_state =
          Map.put(node_state, from_node, signal)

        new_state = Map.put(state, to_node, new_node_state)

        # if all inputs are high, send a low signal to all successors, else send a high signal
        if all_high?(new_node_state),
          do: {broadcast(:low, to_node, successors), new_state, inc_low(counter, ns)},
          else: {broadcast(:high, to_node, successors), new_state, inc_high(counter, ns)}
    end
  end

  # A tick processes all pulses in flight by one hop
  def tick(pulses, state, counter, graph) do
    reduce(pulses, {[], state, counter}, fn pulse, {acc_pulses, st, ct} ->
      {new_pulses, new_state, new_counter} = hop(pulse, st, ct, graph)
      {[acc_pulses | new_pulses], new_state, new_counter}
    end)
    # acc_pulses are list, so flatten them
    |> then(fn {pulses, s, c} -> {List.flatten(pulses), s, c} end)
  end

  def initial_pulse(), do: [{:elve, :button, :low}]
  def run([], state, counter, _graph), do: {state, counter}

  def run(pulses, state, counter, graph) do
    #    IO.inspect({pulses, state, counter}, label: "Run")
    {new_pulses, new_state, new_counter} = tick(pulses, state, counter, graph)
    run(new_pulses, new_state, new_counter, graph)
  end

  def part1(args) do
    graph = args |> parse()

    reduce(1..1000, {inital_state(graph), %{low: 0, high: 0}}, fn _i, {state, counter} ->
      run(initial_pulse(), state, counter, graph)
    end)
    |> then(fn {_state, counter} -> counter[:low] * counter[:high] end)
  end

  def part2(_args) do
    :ok
  end

  def test(_) do
    """
    broadcaster -> a, b, c
    %a -> b
    %b -> c
    %c -> inv
    &inv -> a
    """
  end

  def test2(_) do
    """
    broadcaster -> a
    %a -> inv, con
    &inv -> b
    %b -> con
    &con -> output
    """
  end
end
