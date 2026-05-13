# SPDX-FileCopyrightText: 2026 diffo-dev contributors
# SPDX-License-Identifier: Apache-2.0

defmodule Diffo.Ieee1164Test do
  use ExUnit.Case

  test "yarn/0 returns all sections in order" do
    keys = Diffo.Ieee1164.yarn() |> Enum.map(fn {_, [{key, _}]} -> key end)

    assert keys == [
             :standard,
             :signals,
             :values,
             :character,
             :pairwise,
             :strength,
             :identity_under_resolution,
             :resolutions,
             :is_x,
             :operations,
             :logic_operations,
             :worlds,
             :projections,
             :transitions,
             :synchronicity
           ]
  end

  test "each section parses to an artefact" do
    Diffo.Ieee1164.yarn()
    |> Enum.each(fn {title, [{key, _}]} ->
      artefact = apply(Diffo.Ieee1164, key, [])
      assert Artefact.is_valid?(artefact), "#{title} (#{key}) artefact is not valid"
    end)
  end

  test "ieee1164/0 combines all sections into integrated knowledge" do
    integrated = Diffo.Ieee1164.ieee1164()
    assert Artefact.is_valid?(integrated), "integrated ieee1164 artefact is not valid"

    # Every node from every section survives into the integrated artefact.
    section_node_names =
      Diffo.Ieee1164.yarn()
      |> Enum.flat_map(fn {_, [{key, _}]} ->
        artefact = apply(Diffo.Ieee1164, key, [])
        Enum.map(artefact.graph.nodes, & &1.properties["name"])
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()

    integrated_node_names =
      integrated.graph.nodes
      |> Enum.map(& &1.properties["name"])
      |> Enum.reject(&is_nil/1)

    for name <- section_node_names do
      assert name in integrated_node_names,
             "node \"#{name}\" missing from integrated ieee1164 artefact"
    end
  end

  @tag :integration
  test "compile task writes valid binary artefacts to priv/diffo/ieee1164/" do
    out = Path.join([:code.priv_dir(:ieee1164) |> to_string(), "diffo", "ieee1164"])

    section_bins = Diffo.Ieee1164.yarn() |> Enum.map(fn {_, [{key, _}]} -> "#{key}.bin" end)
    expected = ["ieee1164.bin" | section_bins]

    for filename <- expected do
      path = Path.join(out, filename)
      assert File.exists?(path), "#{path} not found — run `mix ieee1164.compile` first"
      artefact = path |> File.read!() |> :erlang.binary_to_term()
      assert Artefact.is_valid?(artefact), "#{filename} deserialises to an invalid artefact"
    end
  end
end
