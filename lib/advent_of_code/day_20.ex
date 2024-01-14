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

  def inc_low(counter), do: %{counter | low: 1 + counter[:low]}
  def inc_high(counter), do: %{counter | high: 1 + counter[:high]}
  def inc_signal(counter, signal), do: %{counter | signal => 1 + counter[signal]}

  # Flip the state of a flipflop
  def flip(:on), do: :off
  def flip(:off), do: :on
  def flip(state, node), do: Map.put(state, node, flip(Map.get(state, node)))

  # Send a signal to all successors
  def broadcast(signal, successors, from), do: for(to <- successors, do: {to, signal, from})

  def all_high?(l), do: all?(Map.values(l), &(&1 == :high))
  # Execute one hop of the signal
  # ie process one pulse
  # A pulse is a tuple {to_node, signal, from_node}
  # Returns a tuple {new_pulses, new_state, new_counter}
  def hop({node, signal, from_node}, state, counter, graph) do
    IO.inspect({node, signal, from_node, state, counter}, label: "Hop")
    node_state = state[node]
    {node_type, successors} = Map.get(graph, node, {nil, nil})

    cond do
      # button, send a low signal to :broadcaster and increment the low counter
      node_type == :button ->
        {[{:broadcaster, :low, :button}], state, inc_low(counter)}

      # broadcaster, transmit the signal to all successors and increment the signal counter
      node_type == :broadcaster ->
        {broadcast(signal, successors, node), state, inc_signal(counter, signal)}

      # end node, stop the signal
      node_state == nil ->
        {[], state, counter}

      # flipflop receiving a high signal: do nothing
      node_type == :flipflop and signal == :high ->
        {[], state, counter}

      # flipflop receiving a low signal: send a high signal if flipflop on off, a low if flipflop on on, and flip the flipflop
      node_type == :flipflop ->
        signal_to_send = if node_state == :off, do: :high, else: :low

        {broadcast(signal_to_send, successors, node), flip(state, node),
         inc_signal(counter, signal_to_send)}

      # conj
      node_type == :conj ->
        # update memory of the node
        new_node_state =
          Map.put(node_state, from_node, signal) |> IO.inspect(label: "New node state")

        new_state = Map.put(state, node, new_node_state)

        # if all inputs are high, send a low signal to all successors, else send a high signal
        if all_high?(new_node_state) do
          {broadcast(:low, successors, node), new_state, inc_low(counter)}
        else
          {broadcast(:high, successors, node), new_state, inc_high(counter)}
        end
    end
  end

  # A tick processes all pulses in flight by one hop
  def tick(pulses, state, counter, graph) do
    reduce(pulses, {[], state, counter}, fn pulse, {acc_pulses, st, ct} ->
      {new_pulses, new_state, new_counter} = hop(pulse, st, ct, graph)
      IO.inspect(new_pulses, label: "New pulses")
      {[acc_pulses | new_pulses], new_state, new_counter}
    end)
    # acc_pulses are list, so flatten them
    |> then(fn {pulses, s, c} -> {List.flatten(pulses), s, c} end)
  end

  def initial_pulse(), do: [{:button, :low, :elve}]
  def run([], state, counter, _graph), do: {state, counter}

  def run(pulses, state, counter, graph) do
    #    IO.inspect({pulses, state, counter}, label: "Run")
    {new_pulses, new_state, new_counter} = tick(pulses, state, counter, graph)
    run(new_pulses, new_state, new_counter, graph)
  end

  def part1(args) do
    graph = args |> test() |> parse()
    run(initial_pulse(), inital_state(graph), %{low: 0, high: 0}, graph)
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
