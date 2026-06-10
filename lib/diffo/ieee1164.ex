# SPDX-FileCopyrightText: 2026 diffo-dev contributors
# SPDX-License-Identifier: Apache-2.0

defmodule Diffo.Ieee1164 do
  @moduledoc """
  The ieee1164 knowledge graph, expressed as Cypher-style yarn and compiled
  into Artefact form via `Diffo.Ieee1164.Parser`.

  Each section of the yarn is both readable source and a callable function
  returning a self-contained `%Artefact{}`. The title of each artefact is
  derived from its section key; the description is a summary.

  `ieee1164/0` pipelines all sections into the full combined artefact.
  `yarn/0` returns the raw sections for inspection or other tooling.
  """

  require Artefact
  alias Diffo.Ieee1164.Parser

  # ─── Yarn ───────────────────────────────────────────────────────────────

  @standard ~S|
    (STANDARD:{name: "IEEE1164"}) - [DEFINES] -> (SIGNAL:{name: "signal"})
    (STANDARD:{name: "IEEE1164"}) - [DEFINES] -> (VALUE:{name: "value"})
    (STANDARD:{name: "IEEE1164"}) - [DEFINES] -> (RESOLUTION:{name: "resolution"})
    (STANDARD:{name: "IEEE1164"}) - [DEFINES] -> (OPERATION:{name: "operation"})
    (STANDARD:{name: "IEEE1164"}) - [DEFINES] -> (WORLD:{name: "world"})
    (STANDARD:{name: "IEEE1164"}) - [DEFINES] -> (CONCEPT:{name: "transition"})
  |

  @signals ~S|
    (SIGNAL:{name: "signal"}) - [DEFINES] -> (SIGNAL:{name: "std_ulogic"})
    (SIGNAL:{name: "signal"}) - [DEFINES] -> (SIGNAL:{name: "std_logic"})
    (SIGNAL:{name: "signal"}) - [DEFINES] -> (SIGNAL:{name: "std_logic_vector"})
    (SIGNAL:{name: "std_ulogic"}) - [RESOLVES_TO] -> (SIGNAL:{name: "std_logic"})
    (SIGNAL:{name: "std_logic_vector"}) - [SCALES] -> (SIGNAL:{name: "std_logic"})
  |

  @values ~S|
    (VALUE:{name: "value"}) <- [ENUMERATES] - (VALUE:{name: "U"})
    (VALUE:{name: "value"}) <- [ENUMERATES] - (VALUE:{name: "X"})
    (VALUE:{name: "value"}) <- [ENUMERATES] - (VALUE:{name: "0"})
    (VALUE:{name: "value"}) <- [ENUMERATES] - (VALUE:{name: "1"})
    (VALUE:{name: "value"}) <- [ENUMERATES] - (VALUE:{name: "Z"})
    (VALUE:{name: "value"}) <- [ENUMERATES] - (VALUE:{name: "W"})
    (VALUE:{name: "value"}) <- [ENUMERATES] - (VALUE:{name: "L"})
    (VALUE:{name: "value"}) <- [ENUMERATES] - (VALUE:{name: "H"})
    (VALUE:{name: "value"}) <- [ENUMERATES] - (VALUE:{name: "-"})
  |

  @character ~S|
    (VALUE:{name: "value"}) <- [ENUMERATES] - (VALUE:{name: "U", description: "I am unknown"})
    (VALUE:{name: "value"}) <- [ENUMERATES] - (VALUE:{name: "X", description: "I am unknowable"})
    (VALUE:{name: "value"}) <- [ENUMERATES] - (VALUE:{name: "0", description: "I am twin brother of 1"})
    (VALUE:{name: "value"}) <- [ENUMERATES] - (VALUE:{name: "1", description: "I am twin brother of 0"})
    (VALUE:{name: "value"}) <- [ENUMERATES] - (VALUE:{name: "Z", description: "I am you unchanged"})
    (VALUE:{name: "value"}) <- [ENUMERATES] - (VALUE:{name: "W", description: "I can be you unchanged"})
    (VALUE:{name: "value"}) <- [ENUMERATES] - (VALUE:{name: "L", description: "I am twin sister of H"})
    (VALUE:{name: "value"}) <- [ENUMERATES] - (VALUE:{name: "H", description: "I am twin sister of L"})
    (VALUE:{name: "value"}) <- [ENUMERATES] - (VALUE:{name: "-", description: "I am anyone"})
  |

  @pairwise ~S|
    (VALUE:{name: "H"}) - [CONFLICTS_WITH] -> (VALUE:{name: "L"})
    (VALUE:{name: "1"}) - [CONFLICTS_WITH] -> (VALUE:{name: "0"})
    (VALUE:{name: "0"}) - [CONFLICTS_WITH] -> (VALUE:{name: "H"})
    (VALUE:{name: "1"}) - [CONFLICTS_WITH] -> (VALUE:{name: "L"})
    (VALUE:{name: "-"}) - [YIELDS_TO] -> (VALUE:{name: "U"})
    (VALUE:{name: "Z"}) - [YIELDS_TO] -> (VALUE:{name: "value"})
  |

  @strength ~S|
    (VALUE:{name: "0"}) - [FORCES] -> (VALUE:{name: "L"})
    (VALUE:{name: "0"}) - [FORCES] -> (VALUE:{name: "W"})
    (VALUE:{name: "1"}) - [FORCES] -> (VALUE:{name: "H"})
    (VALUE:{name: "1"}) - [FORCES] -> (VALUE:{name: "W"})
    (VALUE:{name: "X"}) - [POISONS] -> (VALUE:{name: "value"})
    (VALUE:{name: "W"}) - [WEAKLY_FORCES] -> (VALUE:{name: "L"})
    (VALUE:{name: "W"}) - [WEAKLY_FORCES] -> (VALUE:{name: "H"})
    (VALUE:{name: "U"}) - [PROPAGATES] -> (VALUE:{name: "value"})
    (VALUE:{name: "-"}) - [POISONS] -> (VALUE:{name: "value"})
  |

  @identity_under_resolution ~S|
    (VALUE:{name: "0"}) - [REMAINS_SELF] -> (VALUE:{name: "0"})
    (VALUE:{name: "1"}) - [REMAINS_SELF] -> (VALUE:{name: "1"})
    (VALUE:{name: "W"}) - [REMAINS_SELF] -> (VALUE:{name: "W"})
    (VALUE:{name: "L"}) - [REMAINS_SELF] -> (VALUE:{name: "L"})
    (VALUE:{name: "H"}) - [REMAINS_SELF] -> (VALUE:{name: "H"})
  |

  @resolutions ~S|
    (RESOLUTION:{name: "resolution"}) <- [ENUMERATES] - (RESOLUTION:{name: "forces", description: "I speak loudest"})
    (RESOLUTION:{name: "resolution"}) <- [ENUMERATES] - (RESOLUTION:{name: "weakly_forces", description: "I speak loudly"})
    (RESOLUTION:{name: "weakly_forces"}) - [YIELDS_TO] -> (RESOLUTION:{name: "forces"})
    (RESOLUTION:{name: "resolution"}) <- [ENUMERATES] - (RESOLUTION:{name: "unknown_overrides_known", description: "I spread uncertainty"})
    (RESOLUTION:{name: "resolution"}) <- [ENUMERATES] - (RESOLUTION:{name: "strength_overrides_conflict", description: "I resolve conflict"})
    (RESOLUTION:{name: "unknown_overrides_known"}) - [CONFLICTS_WITH] -> (RESOLUTION:{name: "strength_overrides_conflict"})
    (SIGNAL:{name: "std_ulogic"}) - [RESOLVES_TO] -> (SIGNAL:{name: "std_logic"})
  |

  @is_x ~S|
    (VALUE:{name: "0"}) - [KNOWABLE] -> (VALUE:{name: "value"})
    (VALUE:{name: "1"}) - [KNOWABLE] -> (VALUE:{name: "value"})
    (VALUE:{name: "L"}) - [KNOWABLE] -> (VALUE:{name: "value"})
    (VALUE:{name: "H"}) - [KNOWABLE] -> (VALUE:{name: "value"})
    (VALUE:{name: "U"}) - [UNKNOWABLE] -> (VALUE:{name: "value"})
    (VALUE:{name: "X"}) - [UNKNOWABLE] -> (VALUE:{name: "value"})
    (VALUE:{name: "Z"}) - [UNKNOWABLE] -> (VALUE:{name: "value"})
    (VALUE:{name: "W"}) - [UNKNOWABLE] -> (VALUE:{name: "value"})
    (VALUE:{name: "-"}) - [UNKNOWABLE] -> (VALUE:{name: "value"})
  |

  @operations ~S|
    (OPERATION:{name: "operation"}) <- [ENUMERATES] - (OPERATION:{name: "NOT", description: "I reveal your opposite. I know your polarity but not your strength."})
    (OPERATION:{name: "operation"}) <- [ENUMERATES] - (OPERATION:{name: "AND", description: "I know zero speaks loudest. Show me one zero and I will silence everything."})
    (OPERATION:{name: "operation"}) <- [ENUMERATES] - (OPERATION:{name: "OR", description: "I know one speaks loudest. Show me one one and I will carry it forward."})
    (OPERATION:{name: "operation"}) <- [ENUMERATES] - (OPERATION:{name: "XOR", description: "I know the difference. Same is silence, different is voice."})
  |

  @logic_operations ~S|
    (OPERATION:{name: "NOT"}) - [INVERTS] -> (VALUE:{name: "0"})
    (OPERATION:{name: "NOT"}) - [INVERTS] -> (VALUE:{name: "1"})
    (OPERATION:{name: "NOT"}) - [INVERTS] -> (VALUE:{name: "L"})
    (OPERATION:{name: "NOT"}) - [INVERTS] -> (VALUE:{name: "H"})
    (OPERATION:{name: "NOT"}) - [REFLECTS] -> (VALUE:{name: "X"})
    (OPERATION:{name: "NOT"}) - [REFLECTS] -> (VALUE:{name: "U"})
    (OPERATION:{name: "NOT"}) - [RESOLVES_TO_X] -> (VALUE:{name: "Z"})
    (OPERATION:{name: "NOT"}) - [RESOLVES_TO_X] -> (VALUE:{name: "W"})
    (OPERATION:{name: "NOT"}) - [RESOLVES_TO_X] -> (VALUE:{name: "-"})
    (OPERATION:{name: "AND"}) - [DOMINATED_BY] -> (VALUE:{name: "0"})
    (OPERATION:{name: "AND"}) - [DOMINATED_BY] -> (VALUE:{name: "L"})
    (OPERATION:{name: "OR"}) - [DOMINATED_BY] -> (VALUE:{name: "1"})
    (OPERATION:{name: "OR"}) - [DOMINATED_BY] -> (VALUE:{name: "H"})
    (OPERATION:{name: "XOR"}) - [SILENCED_BY_SAMENESS] -> (VALUE:{name: "value"})
  |

  @worlds ~S|
    (WORLD:{name: "world"}) <- [ENUMERATES] - (WORLD:{name: "bit_world", description: "I am the oldest world. Two values. True and false."})
    (WORLD:{name: "world"}) <- [ENUMERATES] - (WORLD:{name: "x01_world", description: "I am the synthesis world. I keep certainty and name the rest unknowable."})
    (WORLD:{name: "world"}) <- [ENUMERATES] - (WORLD:{name: "x01z_world", description: "I am the tristate world. I keep the silence of high impedance."})
    (WORLD:{name: "world"}) <- [ENUMERATES] - (WORLD:{name: "ux01_world", description: "I am the reset world. I keep the memory of uninitialised."})
    (WORLD:{name: "world"}) <- [ENUMERATES] - (WORLD:{name: "std_logic_world", description: "I am the simulation world. I hold all nine."})
  |

  @projections ~S|
    (OPERATION:{name: "to_x01"}) - [COLLAPSES_TO] -> (OPERATION:{name: "operation"})
    (OPERATION:{name: "to_x01z"}) - [COLLAPSES_TO] -> (OPERATION:{name: "operation"})
    (OPERATION:{name: "to_ux01"}) - [COLLAPSES_TO] -> (OPERATION:{name: "operation"})
    (WORLD:{name: "std_logic_world"}) - [PROJECTS_TO] -> (WORLD:{name: "x01_world"})
    (WORLD:{name: "std_logic_world"}) - [PROJECTS_TO] -> (WORLD:{name: "x01z_world"})
    (WORLD:{name: "std_logic_world"}) - [PROJECTS_TO] -> (WORLD:{name: "ux01_world"})
    (WORLD:{name: "std_logic_world"}) - [PROJECTS_TO] -> (WORLD:{name: "bit_world"})
    (WORLD:{name: "x01_world"}) - [PROJECTS_TO] -> (WORLD:{name: "bit_world"})
    (VALUE:{name: "L"}) - [SURVIVES_AS] -> (VALUE:{name: "0"})
    (VALUE:{name: "H"}) - [SURVIVES_AS] -> (VALUE:{name: "1"})
    (VALUE:{name: "Z"}) - [SURVIVES_IN] -> (WORLD:{name: "x01z_world"})
    (VALUE:{name: "U"}) - [SURVIVES_IN] -> (WORLD:{name: "ux01_world"})
    (VALUE:{name: "W"}) - [COLLAPSES_TO_X] -> (WORLD:{name: "world"})
    (VALUE:{name: "-"}) - [COLLAPSES_TO_X] -> (WORLD:{name: "world"})
  |

  @transitions ~S|
    (CONCEPT:{name: "transition"}) <- [ENUMERATES] -
    (CONCEPT:{name: "departing", description: "I am what I am leaving"})
    (CONCEPT:{name: "transition"}) <- [ENUMERATES] -
    (CONCEPT:{name: "arriving", description: "I am what I am becoming"})
    (OPERATION:{name: "operation"}) <- [ENUMERATES] -
    (OPERATION:{name: "rising_edge", description: "I know the moment zero becomes one. I see through your strength."})
    (OPERATION:{name: "operation"}) <- [ENUMERATES] -
    (OPERATION:{name: "falling_edge", description: "I know the moment one becomes zero. I see through your strength."})
    (OPERATION:{name: "rising_edge"}) - [READS] -> (CONCEPT:{name: "departing"})
    (OPERATION:{name: "rising_edge"}) - [READS] -> (CONCEPT:{name: "arriving"})
    (OPERATION:{name: "rising_edge"}) - [USES] -> (OPERATION:{name: "to_x01"})
    (OPERATION:{name: "falling_edge"}) - [READS] -> (CONCEPT:{name: "departing"})
    (OPERATION:{name: "falling_edge"}) - [READS] -> (CONCEPT:{name: "arriving"})
    (OPERATION:{name: "falling_edge"}) - [USES] -> (OPERATION:{name: "to_x01"})
  |

  @synchronicity ~S|
    (STANDARD:{name: "IEEE1164"}) - [ENABLES] -> (CONCEPT:{name: "synchronicity", description: "With one breath, with one flow, you will know synchronicity."})
    (CONCEPT:{name: "synchronicity"}) <- [ENUMERATES] -
    (CONCEPT:{name: "clock", description: "I am the heartbeat. I mark the moment of knowing."})
    (CONCEPT:{name: "synchronicity"}) <- [ENUMERATES] -
    (CONCEPT:{name: "sample", description: "I am what is captured at the edge. I am the world between heartbeats."})
    (CONCEPT:{name: "synchronicity"}) <- [ENUMERATES] -
    (CONCEPT:{name: "domain", description: "I am all that shares a heartbeat."})
    (OPERATION:{name: "rising_edge"}) - [MARKS] -> (CONCEPT:{name: "clock"})
    (CONCEPT:{name: "clock"}) - [GOVERNS] -> (CONCEPT:{name: "sample"})
    (CONCEPT:{name: "sample"}) - [BELONGS_TO] -> (CONCEPT:{name: "domain"})
  |

  # ─── Yarn as text ───────────────────────────────────────────────────────

  @doc """
  The raw Cypher-style yarn, in the order the story is told.

  Each entry is `{title, [key: cypher_text]}` — the human sentence that names
  the chapter, the section key, and the Cypher source itself.
  """
  def yarn do
    [
      {"Welcome to the land of IEEE1164", standard: @standard},
      {"My signals live here", signals: @signals},
      {"My signal's children are values", values: @values},
      {"The values each have character", character: @character},
      {"Some values are twinned: conflicting or yielding", pairwise: @pairwise},
      {"Some values impose their strength", strength: @strength},
      {"Some values remain true to self", identity_under_resolution: @identity_under_resolution},
      {"Sometimes uncles must resolve things", resolutions: @resolutions},
      {"There are actually two clans", is_x: @is_x},
      {"But we get things done", operations: @operations},
      {"And this is how", logic_operations: @logic_operations},
      {"We know of other worlds", worlds: @worlds},
      {"And we can pass between them as they are one", projections: @projections},
      {"We live in the moment", transitions: @transitions},
      {"Let's create together", synchronicity: @synchronicity}
    ]
  end

  # ─── Artefacts by section ───────────────────────────────────────────────

  defp section(key) do
    {title, [{^key, text}]} = Enum.find(yarn(), fn {_, [{k, _}]} -> k == key end)
    Parser.parse(text, title: title, description: text)
  end

  def standard, do: section(:standard)
  def signals, do: section(:signals)
  def values, do: section(:values)
  def character, do: section(:character)
  def pairwise, do: section(:pairwise)
  def strength, do: section(:strength)
  def identity_under_resolution, do: section(:identity_under_resolution)
  def resolutions, do: section(:resolutions)
  def is_x, do: section(:is_x)
  def operations, do: section(:operations)
  def logic_operations, do: section(:logic_operations)
  def worlds, do: section(:worlds)
  def projections, do: section(:projections)
  def transitions, do: section(:transitions)
  def synchronicity, do: section(:synchronicity)

  # ─── Load from priv ─────────────────────────────────────────────────────

  @doc """
  Load a pre-compiled section artefact from `priv/diffo/ieee1164/<key>.bin`.

  Run `mix ieee1164.compile` to produce the files. Raises if missing.
  """
  def load(key) when is_atom(key) do
    priv_path("#{key}.bin") |> File.read!() |> :erlang.binary_to_term()
  end

  @doc """
  Load the fully combined ieee1164 artefact from `priv/diffo/ieee1164/ieee1164.bin`.
  """
  def load_ieee1164 do
    priv_path("ieee1164.bin") |> File.read!() |> :erlang.binary_to_term()
  end

  defp priv_path(filename) do
    path = Path.join([:code.priv_dir(:ieee1164) |> to_string(), "diffo", "ieee1164", filename])

    unless File.exists?(path) do
      raise "#{path} not found — run `mix ieee1164.compile` first."
    end

    path
  end

  # ─── Streams ─────────────────────────────────────────────────────────────

  @doc """
  A stream of section artefacts in yarn order, parsed lazily.

  Each element is a self-contained `%Artefact{}` for that section.

      Diffo.Ieee1164.stream() |> Enum.take(3)
  """
  def stream do
    Stream.map(yarn(), fn {title, [{_key, text}]} ->
      Parser.parse(text, title: title, description: text)
    end)
  end

  @doc """
  A stream of progressively integrated artefacts, one section at a time.

  The first element is `:standard` alone. Each subsequent element folds
  the next section into the growing whole — the story as it is told.

      Diffo.Ieee1164.stream_integrated() |> Enum.each(&inspect/1)
  """
  def stream_integrated do
    [{first_title, [{_key, first_text}]} | rest] = yarn()
    initial = Parser.parse(first_text, title: first_title, description: first_text)

    rest_stream =
      Stream.transform(rest, initial, fn {title, [{_key, text}]}, acc ->
        section = Parser.parse(text, title: title, description: text)
        next = Artefact.combine!(acc, section)
        integrating_title = "IEEE1164 integrating: #{title}"

        # Stable identity for the combined artefact so ieee1164.bin (and the
        # provenance that references each step's uuid) is reproducible.
        next = %{
          next
          | title: integrating_title,
            id: Artefact.UUID.from_name(integrating_title <> "#id"),
            uuid: Artefact.UUID.from_name(integrating_title)
        }

        {[next], next}
      end)

    Stream.concat([initial], rest_stream)
  end

  # ─── Full pipeline ──────────────────────────────────────────────────────

  @doc """
  The complete ieee1164 artefact — all sections combined progressively.
  The same story the livebook tells, in compiled form.
  """
  def ieee1164 do
    stream_integrated() |> Enum.at(-1)
  end
end
