# SPDX-FileCopyrightText: 2026 diffo-dev contributors
# SPDX-License-Identifier: Apache-2.0

defmodule Diffo.Ieee1164 do
  @moduledoc """
  Documentation for `Ieee1164`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Diffo.Ieee1164.hello()
      :world

  """
  def hello do
    :world
  end

  @standard ~S|
    (STANDARD:{name: "IEEE1164"}) - [DEFINES] -> (SIGNAL:{name: "signal"})
    (STANDARD:{name: "IEEE1164"}) - [DEFINES] -> (VALUE:{name: "value"})
    (STANDARD:{name: "IEEE1164"}) - [DEFINES] -> (RESOLUTION:{name: "resolution"})
    (STANDARD:{name: "IEEE1164"}) - [DEFINES] -> (OPERATION:{name: "operation"})
    (STANDARD:{name: "IEEE1164"}) - [DEFINES] -> (PROJECTION:{name: "projection"})
    (STANDARD:{name: "IEEE1164"}) - [DEFINES] -> (WORLD:{name: "world"})
    (STANDARD:{name: "IEEE1164"}) - [DEFINES] -> (CONCEPT:{name: "transition"})
  |

  @signals ~S|
    (SIGNAL:{name: "signal"}) - [DEFINES] -> (SIGNAL:{name: "std_ulogic"})
    (SIGNAL:{name: "signal"}) - [DEFINES] -> (SIGNAL:{name: "std_logic"})
    (SIGNAL:{name: "signal"}) - [DEFINES] -> (SIGNAL:{name: "std_logic_vector"})
    (SIGNAL:{name: "std_ulogic"}) - [RESOLVES] -> (SIGNAL:{name: "std_logic"})
    (SIGNAL:{name: "std_logic_vector"}) - [SCALES] -> (SIGNAL:{name: "std_logic"})
  |

  @values ~S|
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

  @character ~S|
    (VALUE:{name: "U"}) - [PROPAGATES] -> (VALUE:{name: "value"})
    (VALUE:{name: "X"}) - [FORCES] -> (VALUE:{name: "value"})
    (VALUE:{name: "Z"}) - [YIELDING] -> (VALUE:{name: "value"})
    (VALUE:{name: "-"}) - [POISONS] -> (VALUE:{name: "value"})
  |

  @pairwise ~S|
    (VALUE:{name: "0"}) - [CONFLICTS_WITH] -> (VALUE:{name: "1"})
    (VALUE:{name: "L"}) - [CONFLICTS_WITH] -> (VALUE:{name: "H"})
    (VALUE:{name: "-"}) - [YIELDS_TO] -> (VALUE:{name: "U"})
  |

  @strength ~S|
    (VALUE:{name: "0"}) - [FORCES] -> (VALUE:{name: "L"})
    (VALUE:{name: "0"}) - [FORCES] -> (VALUE:{name: "H"})
    (VALUE:{name: "1"}) - [FORCES] -> (VALUE:{name: "L"})
    (VALUE:{name: "1"}) - [FORCES] -> (VALUE:{name: "H"})
    (VALUE:{name: "W"}) - [WEAKLY_FORCES] -> (VALUE:{name: "L"})
    (VALUE:{name: "W"}) - [WEAKLY_FORCES] -> (VALUE:{name: "H"})
  |

  @identity_under_resolution ~S|
    (VALUE:{name: "0"}) - [REMAINS_SELF] -> (VALUE:{name: "0"})
    (VALUE:{name: "1"}) - [REMAINS_SELF] -> (VALUE:{name: "1"})
    (VALUE:{name: "L"}) - [REMAINS_SELF] -> (VALUE:{name: "L"})
    (VALUE:{name: "H"}) - [REMAINS_SELF] -> (VALUE:{name: "H"})
    (VALUE:{name: "W"}) - [REMAINS_SELF] -> (VALUE:{name: "W"})
  |

  @resolutions ~S|
    (RESOLUTION:{name: "resolution"}) <- [ENUMERATES] - (RESOLUTION:{name: "forces", description: "I speak loudest"})
    (RESOLUTION:{name: "resolution"}) <- [ENUMERATES] - (RESOLUTION:{name: "weakly_forces", description: "I speak loudly"})
    (RESOLUTION:{name: "weakly_forces"}) - [YIELDS_TO] -> (RESOLUTION:{name: "forces"})
    (RESOLUTION:{name: "resolution"}) <- [ENUMERATES] - (RESOLUTION:{name: "unknown_overrides_known", description: "I spread uncertainty"})
    (RESOLUTION:{name: "resolution"}) <- [ENUMERATES] - (RESOLUTION:{name: "strength_overrides_conflict", description: "I resolve conflict"})
    (RESOLUTION:{name: "unknown_overrides_known"}) - [CONFLICTS_WITH] -> (RESOLUTION:{name: "strength_overrides_conflict"})
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
    (OPERATION:{name: "operation"}) <- [ENUMERATES] -
      (OPERATION:{name: "NOT",
        description: "I reveal your opposite. I know your polarity but not your strength."})
    (OPERATION:{name: "operation"}) <- [ENUMERATES] -
      (OPERATION:{name: "AND",
        description: "I know zero speaks loudest. Show me one zero and I will silence everything."})
    (OPERATION:{name: "operation"}) <- [ENUMERATES] -
      (OPERATION:{name: "OR",
        description: "I know one speaks loudest. Show me one one and I will carry it forward."})
    (OPERATION:{name: "operation"}) <- [ENUMERATES] -
      (OPERATION:{name: "XOR",
        description: "I know the difference. Same is silence, different is voice."})
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
    (WORLD:{name: "world"}) <- [ENUMERATES] -
    (WORLD:{name: "bit_world",
        description: "I am the oldest world. Two values. True and false."})
    (WORLD:{name: "world"}) <- [ENUMERATES] -
      (WORLD:{name: "x01_world",
        description: "I am the synthesis world. I keep certainty and name the rest unknowable."})
    (WORLD:{name: "world"}) <- [ENUMERATES] -
      (WORLD:{name: "x01z_world",
        description: "I am the tristate world. I keep the silence of high impedance."})
    (WORLD:{name: "world"}) <- [ENUMERATES] -
      (WORLD:{name: "ux01_world",
        description: "I am the reset world. I keep the memory of uninitialised."})
    (WORLD:{name: "world"}) <- [ENUMERATES] -
      (WORLD:{name: "std_logic_world",
        description: "I am the simulation world. I hold all nine."})

    (WORLD:{name: "std_logic_world"}) - [PROJECTS_TO] -> (WORLD:{name: "x01_world"})
    (WORLD:{name: "std_logic_world"}) - [PROJECTS_TO] -> (WORLD:{name: "x01z_world"})
    (WORLD:{name: "std_logic_world"}) - [PROJECTS_TO] -> (WORLD:{name: "ux01_world"})
    (WORLD:{name: "std_logic_world"}) - [PROJECTS_TO] -> (WORLD:{name: "bit_world"})
    (WORLD:{name: "x01_world"}) - [PROJECTS_TO] -> (WORLD:{name: "bit_world"})
  |

  @projections ~S|
    (PROJECTION:{name: "projection"}) <- [ENUMERATES] -
      (PROJECTION:{name: "to_x01",
        description: "I collapse to three. What I cannot name, I call unknowable."})
    (PROJECTION:{name: "projection"}) <- [ENUMERATES] -
      (PROJECTION:{name: "to_x01z",
        description: "I collapse to four. I keep the silence of high impedance."})
    (PROJECTION:{name: "projection"}) <- [ENUMERATES] -
      (PROJECTION:{name: "to_ux01",
        description: "I collapse to four. I keep the memory of the uninitialised."})

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
      (OPERATION:{name: "rising_edge",
        description: "I know the moment zero becomes one. I see through your strength."})
    (OPERATION:{name: "operation"}) <- [ENUMERATES] -
      (OPERATION:{name: "falling_edge",
        description: "I know the moment one becomes zero. I see through your strength."})

    (OPERATION:{name: "rising_edge"}) - [READS] -> (CONCEPT:{name: "departing"})
    (OPERATION:{name: "rising_edge"}) - [READS] -> (CONCEPT:{name: "arriving"})
    (OPERATION:{name: "rising_edge"}) - [USES] -> (PROJECTION:{name: "to_x01"})

    (OPERATION:{name: "falling_edge"}) - [READS] -> (CONCEPT:{name: "departing"})
    (OPERATION:{name: "falling_edge"}) - [READS] -> (CONCEPT:{name: "arriving"})
    (OPERATION:{name: "falling_edge"}) - [USES] -> (PROJECTION:{name: "to_x01"})
  |

  @synchronicity ~S|
    (STANDARD:{name: "IEEE1164"}) - [ENABLES] -> (CONCEPT:{name: "synchronicity", "description: "With one breath, with one flow, you will know synchronicity."})
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

  def yarn do
    [
      {"Welcome to the land of IEEE1164", standard: @standard},
      {"My signals live here", signals: @signals},
      {"My signal's children are values",  values: @values},
      {"The values each have character", character: @character},
      {"Some values are twinned: conflicting or yeilding", pairwise: @pairwise},
      {"Some values impose their strength", strength: @strength},
      {"Some values remain true to self", identity_under_resolution: @identity_under_resolution},
      {"Sometimes uncles must resolve things", resolutions: @resolutions},
      {"There are actually two clans", is_x: @is_x},
      {"But we get things done", operations: @operations},
      {"And this is how", logic_operations: @logic_operations},
      {"We know of other worlds", worlds: @worlds},
      {"And we can pass between them as they are one", projections: @projections},
      {"We live in the moment", transitions: @transitions},
      {"Let's create together", synchronicity: @synchronicity},
    ]
  end
end
