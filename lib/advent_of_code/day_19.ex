defmodule AdventOfCode.Day19 do
  ##### PARSING #####
  def parse2(p2) do
    for line <- String.split(p2, "\n", trim: true) do
      [x, m, a, s] =
        Regex.scan(~r/\d+/, line)
        |> List.flatten()
        |> Enum.map(&String.to_integer/1)

      %{x: x, m: m, a: a, s: s}
    end
  end

  def wf_type("A"), do: :accepted
  def wf_type("R"), do: :rejected
  def wf_type(wf), do: wf

  def parse_test(t) do
    if String.contains?(t, "<") do
      [t, v] = String.split(t, "<", trim: true)
      {String.to_atom(t), :lt, String.to_integer(v)}
    else
      [t, v] = String.split(t, ">", trim: true)
      {String.to_atom(t), :gt, String.to_integer(v)}
    end
  end

  def parse_line(line) do
    [wf, conds] = Regex.scan(~r/(.*){(.*?)}/, line, capture: :all_but_first) |> List.flatten()

    process =
      for c <- String.split(conds, ",", trim: true) do
        if String.contains?(c, ":") do
          [t, wfo] = String.split(c, ":", trim: true)
          {parse_test(t), wf_type(wfo)}
        else
          wf_type(c)
        end
      end

    {wf, process}
  end

  def parse1(p1) do
    for line <- String.split(p1, "\n", trim: true), into: %{}, do: parse_line(line)
  end

  # Data structure:
  # {instructions, data}
  # instructions: %{"in" => [{{:x, :gt, 1}, :accepted}, {{:x, :lt, 4000}, "otherwf"}, :rejected], ...}
  # data : [%{x: 1, m: 2, a: 3, s: 4}, ...]
  def parse(args) do
    [p1, p2] = String.split(args, "\n\n", trim: true)
    {parse1(p1), parse2(p2)}
  end

  ###### PART1 : SIMPLE EXECUTION #####

  # Execute one condition
  # if the condition is true, return the output
  # else, execute the next condition
  def execute([{{a, comp, n}, out} | r], data) do
    if (comp == :gt and data[a] > n) or (comp == :lt and data[a] < n),
      do: out,
      else: execute(r, data)
  end

  # If we reach the end of the workflow, return the output (accepted or rejected, of the next workflow)
  def execute([out], _), do: out

  # Execute one workflow
  # Stop if accepted or rejected
  # Else, execute the next workflow
  def execute(rules, wf, data) do
    case execute(rules[wf], data) do
      :accepted -> :accepted
      :rejected -> :rejected
      out -> execute(rules, out, data)
    end
  end

  def part1(args) do
    # parse rules and data
    {rules, data} = args |> parse()
    # For each data, execute the rules
    # filter on :accepted and sum the values
    for d <- data, execute(rules, "in", d) == :accepted do
      d |> Map.values() |> Enum.sum()
    end
    |> Enum.sum()
  end

  #### PART2 ######
  # let {l,h} an interval
  # the gt and lt functions "cut" the interval into 2 intervals, one for which the condition is true and one for which it is false
  # for example, if we have x in [1000,2000] and we have the condition x<1500, then the intervals are [1000, 1499] and [1500, 2000]
  def gt(n, {l, h}) when h <= n, do: {nil, {l, h}}
  def gt(n, {l, h}) when l > n, do: {{l, h}, nil}
  def gt(n, {l, h}), do: {{n + 1, h}, {l, n}}

  def lt(n, {l, h}) when l >= n, do: {nil, {l, h}}
  def lt(n, {l, h}) when h < n, do: {{l, h}, nil}
  def lt(n, {l, h}), do: {{l, n - 1}, {n, h}}

  # Core of the work
  # the idea is to branch the execution of the condition.
  # We concatenate the 2 hypothesis: all the results for which the condition is true and all the result for which the condition is false
  # For example, if the condition is x>1000:gxp and the ranges contain the interval x: {500, 3000}
  # We add the case for which we execute the condition "go to workflow gxp" with the interval x: {1001, 3000} and we add the
  # result of the case where we go to the next condition with the interval x: {500, 1000}
  # Ranges: for example %{x: {500, 3000}, m: {1, 4000}, a: {1, 4000}, s: {1, 4000}}
  def execute2(rules, [{{a, comp, n}, out} | r], ranges) do
    # Compute the 2 intervals (when cond is true and when cond is false)
    {n_true, n_false} = if comp == :gt, do: gt(n, ranges[a]), else: lt(n, ranges[a])

    # if there is no interval for which the condition is true, we don't branch and we continue the execution of the process
    if n_true == nil do
      execute2(rules, r, Map.put(ranges, a, n_false))
    else
      # Otherwise, we branch the execution: either we stop the execution with an accepted result, or we continue the execution to the next workflow
      # in all cases, we use the n_true interval
      # we add the result of the execution of the next condition with the n_false interval
      case out do
        :accepted -> [Map.put(ranges, a, n_true)]
        :rejected -> []
        wf -> execute2(rules, rules[wf], Map.put(ranges, a, n_true))
      end ++
        execute2(rules, r, Map.put(ranges, a, n_false))
    end
  end

  # last step of a process: always true
  def execute2(rules, [out], ranges) do
    case out do
      :accepted -> [ranges]
      :rejected -> []
      # continue the execution with the next workflow
      wf -> execute2(rules, rules[wf], ranges)
    end
  end

  # Compute the volume of a cube defined by a set of ranges
  def cube_volume(ranges),
    do: Enum.reduce(ranges, 1, fn {_, {l, h}}, acc -> acc * (h - l + 1) end)

  def part2(args) do
    {rules, _data} = args |> parse()

    # Start with a set of ranges containing all the values. Find all the possible "parallelipièdes" and compute their volume
    execute2(rules, rules["in"], %{x: {1, 4000}, m: {1, 4000}, a: {1, 4000}, s: {1, 4000}})
    # compute the volume of each "parallelipède"
    |> Enum.map(&cube_volume/1)
    |> Enum.sum()
  end
end
