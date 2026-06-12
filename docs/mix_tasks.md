<!--
SPDX-FileCopyrightText: 2026 diffo-dev
SPDX-License-Identifier: Apache-2.0
-->

# Mix Tasks

The ieee1164 knowledge compiler pipeline is driven by two Mix tasks.
Run them in order whenever the yarn changes.

```sh
mix ieee1164.gen_uuids
mix ieee1164.compile
```

Both tasks require the application to be started (`app.start` is called internally).

---

## `mix ieee1164.gen_uuids`

Walks the ieee1164 yarn, collects every `name` property, and assigns each a
stable UUIDv7. Existing entries are preserved — only names not yet in the file
receive a new UUID.

**Output:** `priv/diffo/ieee1164/uuids.exs`

```sh
mix ieee1164.gen_uuids
# priv/diffo/ieee1164/uuids.exs: 42 total (3 new)
```

Run this task once after adding new nodes to the yarn, then commit
`priv/diffo/ieee1164/uuids.exs`. The file is the stable identity of every node
across the diffo universe — the same name always carries the same UUID.

When a registry or Artefactory service is available, this step becomes a push
to that service rather than a file write.

---

## `mix ieee1164.compile`

Parses each section of the ieee1164 yarn into an `%Artefact{}` and serialises
it to `priv/diffo/ieee1164/<section>.bin` using `:erlang.term_to_binary/1`.
Also writes the fully integrated `ieee1164.bin`.

**Requires:** `priv/diffo/ieee1164/uuids.exs` (run `gen_uuids` first)

**Output:** `priv/diffo/ieee1164/*.bin`

```sh
mix ieee1164.compile
#   wrote priv/diffo/ieee1164/standard.bin
#   wrote priv/diffo/ieee1164/signals.bin
#   wrote priv/diffo/ieee1164/values.bin
#   wrote priv/diffo/ieee1164/resolutions.bin
#   wrote priv/diffo/ieee1164/operations.bin
#   wrote priv/diffo/ieee1164/projections.bin
#   wrote priv/diffo/ieee1164/transitions.bin
#   wrote priv/diffo/ieee1164/synchronicity.bin
#   wrote priv/diffo/ieee1164/ieee1164.bin
# priv/diffo/ieee1164: 9 artefacts compiled
```

Commit the `.bin` files so livebooks and other consumers can load artefacts
directly without re-parsing.

---

## Loading artefacts at runtime

Section artefacts and the integrated artefact can be loaded from the compiled
binaries without re-parsing the yarn:

```elixir
# A single section
Ieee1164.load(:values)

# The fully integrated ieee1164 artefact
Ieee1164.load_ieee1164()
```

Both raise with a clear message if `mix ieee1164.compile` has not been run.

---

## Testing

The standard test suite runs without any prior build steps:

```sh
mix test
```

The compile task test is tagged `:integration` and excluded by default — it
requires the `.bin` files to exist. Run the full suite with:

```sh
mix ieee1164.gen_uuids
mix ieee1164.compile
mix test --include integration
```

---

## `priv/diffo/ieee1164/` layout

```
priv/diffo/ieee1164/
├── uuids.exs          ← stable UUIDv7s keyed by node name  (gen_uuids)
├── standard.bin       ─╮
├── signals.bin         │
├── values.bin          │
├── resolutions.bin     ├─ compiled section artefacts        (compile)
├── operations.bin      │
├── projections.bin     │
├── transitions.bin     │
├── synchronicity.bin  ─╯
└── ieee1164.bin       ← fully integrated artefact           (compile)
```

---

## `mix ieee1164.gen_pngs`

A glyph utility, separate from the compiler pipeline. Rasterises every
`images/glyphs/*.svg` to a PNG beside it — for sharing where SVG pastes as
text rather than an image (Discord, WhatsApp). The SVGs stay the source of
truth; the PNGs are generated and git-ignored.

```sh
mix ieee1164.gen_pngs
#   std_logic_1164_black.png
#   ...
# 8 glyphs rendered to images/glyphs/ (zoom 2.0)
```

`--zoom` sets the output resolution — the SVGs are 560px wide, so the default
of 2 renders at 1120px:

```sh
mix ieee1164.gen_pngs --zoom 3
```

Uses `resvg` (a dev-only dependency).
