# SPDX-FileCopyrightText: 2026 diffo-dev
# SPDX-License-Identifier: Apache-2.0

defmodule Mix.Tasks.Ieee1164.GenUuids do
  use Mix.Task

  @shortdoc "Generate stable UUIDv7s for all ieee1164 nodes and write to priv/uuids.exs"

  @moduledoc """
  Walks the ieee1164 yarn, collects every node name, and assigns each a
  stable UUIDv7. Existing entries in `priv/uuids.exs` are preserved —
  only names not yet in the file receive a new UUID.

  Run once after adding new nodes to the yarn:

      mix ieee1164.gen_uuids

  Commit `priv/uuids.exs` so the UUIDs are stable across the diffo universe.
  """

  @path "priv/diffo/ieee1164/uuids.exs"

  def run(_args) do
    Mix.Task.run("app.start")

    names =
      Ieee1164.yarn()
      |> Enum.flat_map(fn {_title, [{_key, text}]} ->
        Regex.scan(~r/name:\s*"([^"]+)"/, text)
        |> Enum.map(fn [_, name] -> name end)
      end)
      |> Enum.uniq()
      |> Enum.sort()

    existing =
      if File.exists?(@path) do
        {map, _} = Code.eval_file(@path)
        map
      else
        %{}
      end

    uuids =
      Enum.reduce(names, existing, fn name, acc ->
        if Map.has_key?(acc, name),
          do: acc,
          else: Map.put(acc, name, Artefact.UUID.generate_v7())
      end)

    File.mkdir_p!("priv")

    content =
      uuids
      |> Enum.sort_by(fn {name, _} -> name end)
      |> Enum.map_join(",\n", fn {name, uuid} -> ~s(  "#{name}" => "#{uuid}") end)

    File.write!(@path, "%{\n#{content}\n}\n")

    added = map_size(uuids) - map_size(existing)
    Mix.shell().info("#{@path}: #{map_size(uuids)} total (#{added} new)")
  end
end
