# SPDX-FileCopyrightText: 2026 diffo-dev contributors
# SPDX-License-Identifier: Apache-2.0

defmodule Diffo.Ieee1164.ResolverTest do
  use ExUnit.Case, async: true

  alias Diffo.Ieee1164.Resolver

  # The hard-coded resolution_table from std_logic_1164-body.vhdl, in the
  # standard's order: U X 0 1 Z W L H -. This is the ORACLE — the resolver
  # derives its own matrix from the graph; here we check the two agree.
  @standard [
    ~w(U U U U U U U U U),
    ~w(U X X X X X X X X),
    ~w(U X 0 X 0 0 0 0 X),
    ~w(U X X 1 1 1 1 1 X),
    ~w(U X 0 1 Z W L H X),
    ~w(U X 0 1 W W W W X),
    ~w(U X 0 1 L W L W X),
    ~w(U X 0 1 H W W H X),
    ~w(U X X X X X X X X)
  ]

  test "the derived matrix is a u8 tensor of shape {9, 9}" do
    t = Resolver.matrix()
    assert Nx.type(t) == {:u, 8}
    assert Nx.shape(t) == {9, 9}
  end

  test "the derived matrix matches the standard resolution_table" do
    order = Resolver.order()

    expected =
      @standard
      |> Enum.map(fn row -> Enum.map(row, &Enum.find_index(order, fn v -> v == &1 end)) end)
      |> Nx.tensor(type: :u8)

    assert Resolver.matrix() == expected
  end

  test "a single driver resolves to itself (the single-driver carve-out)" do
    for v <- Resolver.order(), do: assert(Resolver.resolve([v]) == v)
  end

  test "two don't-care drivers resolve to X, but a lone don't-care stays -" do
    assert Resolver.resolve(["-"]) == "-"
    assert Resolver.resolve(["-", "-"]) == "X"
  end

  test "resolution disregards order (commutative)" do
    order = Resolver.order()

    for a <- order, b <- order do
      assert Resolver.resolve([a, b]) == Resolver.resolve([b, a])
    end
  end

  test "n-ary resolution folds successively (U propagates through a bus)" do
    assert Resolver.resolve(~w(0 1 Z)) == "X"
    assert Resolver.resolve(~w(Z Z L)) == "L"
    assert Resolver.resolve(~w(0 0 0)) == "0"
    assert Resolver.resolve(~w(0 1 U)) == "U"
  end

  test "resolve accepts u8 index lists and 1-d tensors, staying in index space" do
    # 0, 1 -> X  ⇒  indices [2, 3] -> 1
    assert Resolver.resolve([2, 3]) == 1
    # single-driver carve-out in index space: lone `-` (8) stays 8; the pair -> X (1)
    assert Resolver.resolve([8]) == 8
    assert Resolver.resolve([8, 8]) == 1

    # a 1-d tensor of drivers resolves to a scalar :u8 tensor
    answer = Resolver.resolve(Nx.tensor([2, 3, 4], type: :u8))
    assert Nx.type(answer) == {:u, 8}
    assert Nx.shape(answer) == {}
    assert Nx.to_number(answer) == 1
  end

  test "u8 resolve agrees with string resolve over every pair" do
    order = Resolver.order()

    for a <- 0..8, b <- 0..8 do
      via_string = Resolver.resolve([Enum.at(order, a), Enum.at(order, b)])
      assert Resolver.resolve([a, b]) == Enum.find_index(order, &(&1 == via_string))
    end
  end
end
