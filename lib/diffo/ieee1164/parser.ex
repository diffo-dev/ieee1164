# SPDX-FileCopyrightText: 2026 diffo-dev contributors
# SPDX-License-Identifier: Apache-2.0

defmodule Diffo.Ieee1164.Parser do
  @moduledoc """
  Parses ieee1164 Cypher-style yarn strings into `%Artefact{}` structs.

  The first stage of the ieee1164 knowledge compiler pipeline. Yarn strings
  are the human-readable source of truth — written close to the standard
  itself. This module bridges from yarn to Artefactory.

  Node identity is the `name` property value, which is unique across the
  full ieee1164 graph. UUIDs are derived deterministically from the name so
  the same node appearing in different sections always produces the same UUID,
  enabling `Artefact.combine!/2` to bind shared nodes across pipeline stages.
  """

  require Artefact

  @doc """
  Parse a Cypher-style yarn string into an `%Artefact{}`.

  Accepts `:title` and `:description` in opts.
  """
  def parse(yarn, opts \\ []) do
    title = Keyword.get(opts, :title)
    description = Keyword.get(opts, :description)

    statements =
      yarn
      |> preprocess()
      |> Enum.map(&parse_statement/1)
      |> Enum.reject(&is_nil/1)

    uuids = load_uuids()
    registry = build_registry(statements, uuids)
    nodes = registry_to_nodes(registry)
    relationships = build_relationships(statements, registry)

    # Stable artefact identity — derive id/uuid deterministically from the
    # section's title so recompiling unchanged yarn produces byte-identical
    # output (no churn). Node uuids are already stable via priv/uuids.exs.
    seed = title || description || ""

    Artefact.new!(
      title: title,
      description: description,
      base_label: nil,
      nodes: nodes,
      relationships: relationships,
      id: Artefact.UUID.from_name(seed <> "#id"),
      uuid: Artefact.UUID.from_name(seed)
    )
  end

  # ─── Preprocessing ──────────────────────────────────────────────────────

  defp preprocess(yarn) do
    yarn
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> join_continuations()
    |> Enum.reject(&skip?/1)
  end

  defp skip?(line), do: line == "" or String.starts_with?(line, "//")

  # Join lines where a statement spans multiple lines:
  # - unclosed parentheses pull the next line in
  # - a line ending with bare " -" (split relationship arrow) pulls the next line in
  defp join_continuations(lines) do
    lines
    |> Enum.reduce([], fn line, acc ->
      delta = count_char(line, ?() - count_char(line, ?))

      case acc do
        [{prev, open} | rest] when open > 0 ->
          [{prev <> " " <> line, open + delta} | rest]

        [{prev, open} | rest] ->
          if String.ends_with?(prev, " -") do
            [{prev <> " " <> line, open + delta} | rest]
          else
            [{line, delta} | acc]
          end

        [] ->
          [{line, delta} | acc]
      end
    end)
    |> Enum.map(fn {line, _} -> line end)
    |> Enum.reverse()
  end

  defp count_char(str, char) do
    str |> String.to_charlist() |> Enum.count(&(&1 == char))
  end

  # ─── Statement parsing ──────────────────────────────────────────────────

  defp parse_statement(line) do
    cond do
      # Forward: (A) - [REL] -> (B)
      m = Regex.run(~r/^\((.+)\)\s*-\s*\[(\w+)\]\s*->\s*\((.+)\)\s*$/, line) ->
        [_, from_raw, type, to_raw] = m
        parse_triple(from_raw, type, to_raw)

      # Backward: (A) <- [REL] - (B)  →  store as B → A
      m = Regex.run(~r/^\((.+)\)\s*<-\s*\[(\w+)\]\s*-\s*\((.+)\)\s*$/, line) ->
        [_, to_raw, type, from_raw] = m
        parse_triple(from_raw, type, to_raw)

      true ->
        nil
    end
  end

  defp parse_triple(from_raw, type, to_raw) do
    with {:ok, from} <- parse_node(from_raw),
         {:ok, to} <- parse_node(to_raw) do
      {:triple, from, type, to}
    else
      _ -> nil
    end
  end

  # Parse "LABEL:{key: \"val\", ...}" → {label, %{"key" => "val"}}
  defp parse_node(raw) do
    case Regex.run(~r/^(\w+):\{(.*)\}\s*$/s, String.trim(raw)) do
      [_, label, props_raw] -> {:ok, {label, parse_properties(props_raw)}}
      _ -> {:error, :bad_node}
    end
  end

  defp parse_properties(raw) do
    ~r/(\w+):\s*"([^"]*)"/
    |> Regex.scan(raw)
    |> Map.new(fn [_, k, v] -> {k, v} end)
  end

  # ─── Registry ───────────────────────────────────────────────────────────

  # name property is unique across the whole ieee1164 graph — key on it.
  # Registry: name → {atom_key, uuid, label, properties}

  defp build_registry(statements, uuids) do
    statements
    |> Enum.flat_map(fn {:triple, from, _type, to} -> [from, to] end)
    |> Enum.reduce(%{}, fn {label, props}, acc ->
      name = Map.get(props, "name", "")

      case Map.get(acc, name) do
        nil ->
          uuid = Map.fetch!(uuids, name)
          Map.put(acc, name, {atom_key(name), uuid, label, props})

        {ak, uuid, lbl, existing} ->
          # Enrich — first-seen wins on property conflicts
          Map.put(acc, name, {ak, uuid, lbl, Map.merge(props, existing)})
      end
    end)
  end

  defp registry_to_nodes(registry) do
    Enum.map(registry, fn {_name, {ak, uuid, label, props}} ->
      {ak, [labels: [label], properties: props, uuid: uuid]}
    end)
  end

  defp build_relationships(statements, registry) do
    statements
    |> Enum.map(fn {:triple, {_fl, fp}, type, {_tl, tp}} ->
      from_name = Map.get(fp, "name", "")
      to_name = Map.get(tp, "name", "")

      case {Map.get(registry, from_name), Map.get(registry, to_name)} do
        {{from_ak, _, _, _}, {to_ak, _, _, _}} ->
          [from: from_ak, type: type, to: to_ak]

        _ ->
          nil
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
  end

  # ─── UUID from priv/uuids.exs ───────────────────────────────────────────

  # UUIDs are stable UUIDv7s generated once by `mix ieee1164.gen_uuids` and
  # committed to priv/uuids.exs. The same name always yields the same UUID
  # across the diffo universe. Loaded once per parse call.

  defp load_uuids do
    path =
      :code.priv_dir(:ieee1164)
      |> to_string()
      |> Path.join("diffo/ieee1164/uuids.exs")

    unless File.exists?(path) do
      raise """
      priv/uuids.exs not found — run `mix ieee1164.gen_uuids` first.
      """
    end

    {map, _} = Code.eval_file(path)
    map
  end

  defp atom_key(name) do
    slug =
      name
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9]+/, "_")
      |> String.trim("_")

    :"n_#{slug}"
  end
end
