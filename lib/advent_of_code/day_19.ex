defmodule AdventOfCode.Day19 do
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

  def parse(args) do
    [p1, p2] = String.split(args, "\n\n", trim: true)
    {parse1(p1), parse2(p2)}
  end

  def execute([], _), do: :rejected

  def execute([{{a, comp, n}, out} | r], data) do
    if (comp == :gt and data[a] > n) or (comp == :lt and data[a] < n),
      do: out,
      else: execute(r, data)
  end

  def execute([out], _), do: out

  def execute(rules, wf, data) do
    case execute(rules[wf], data) do
      :accepted -> :accepted
      :rejected -> :rejected
      out -> execute(rules, out, data)
    end
  end

  def part1(args) do
    {rules, data} = args |> parse()

    for d <- data, execute(rules, "in", d) == :accepted do
      d |> Map.values() |> Enum.sum()
    end
    |> Enum.sum()
  end

  def part2(_args) do
    :ok
  end

  def test(_) do
    """
    px{a<2006:qkq,m>2090:A,rfg}
    pv{a>1716:R,A}
    lnx{m>1548:A,A}
    rfg{s<537:gd,x>2440:R,A}
    qs{s>3448:A,lnx}
    qkq{x<1416:A,crn}
    crn{x>2662:A,R}
    in{s<1351:px,qqz}
    qqz{s>2770:qs,m<1801:hdj,R}
    gd{a>3333:R,R}
    hdj{m>838:A,pv}

    {x=787,m=2655,a=1222,s=2876}
    {x=1679,m=44,a=2067,s=496}
    {x=2036,m=264,a=79,s=2244}
    {x=2461,m=1339,a=466,s=291}
    {x=2127,m=1623,a=2188,s=1013}
    """
  end
end
