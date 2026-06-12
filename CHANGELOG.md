# Changelog

All notable changes to this project will be documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-06-12

### Changed

- **Breaking:** renamed modules `Diffo.Ieee1164.*` → `Ieee1164.*`, with sources moved to `lib/ieee1164/`. Frees the `Diffo.Ieee1164.*` namespace.
- Modelled the world relationship as an `EXTENDS` lattice (an outer world extends its inner worlds, with the `x01z`/`ux01` diamond joining at `ux01z`).
- `is_x` is now an operation; the two clans are intrinsic to values as `OBSERVABLE` / `UNOBSERVABLE`, and the resolver derives its conflict tier from that.
- Synchronicity `clock` and `sample` are kind-agnostic instances (`INSTANCE_OF` the abstract `signal` / `value`); `domain` is a concept.
- Simplified copyright lines to `© diffo-dev` across SPDX, NOTICE, and REUSE.

### Added

- `ux01z_world`, the `std_ulogic_vector` signal, and the synchronicity layer in the yarn.
- `std_logic_1164_worlds.svg` glyph and a knowing-livebook section drawing the projection worlds as nested **closed** regions of the resolution matrix (with `bit` the non-closing 1076 counterpoint).
- `mix ieee1164.gen_pngs` — render the glyph SVGs to shareable PNGs via `resvg` (dev-only); SVGs remain the source of truth.

### Removed

- The stale, unread `priv/diffo/ieee1164/ieee1164.txt`.

## [0.1.1] - 2026-05-13

### Fixed knowing std_logic_1164 livebook to use repo if local files unavailable

## [0.1.0] - 2026-05-13

### Added

- IEEE 1164 knowledge graph expressed as Cypher-style yarn and compiled into `%Artefact{}` form
- `Diffo.Ieee1164.stream/0` and `Diffo.Ieee1164.stream_integrated/0` for progressive artefact access
- Mix tasks `ieee1164.gen_uuids` and `ieee1164.compile` for the build pipeline
- Livebook: *Yarning with IEEE 1164* — an interactive chapter-by-chapter journey through the standard
- Livebook: *Knowing std_logic_1164* — valuing, being, knowing, and doing with what was learned
- SVG glyphs memorialising the resolution matrix in four eras: Dark Mode, Green Phosphor, Hercules, and X11
- SVG glyphs for the pre-journey (unknown) and instructional (matrix, black key) states
- REUSE-compliant licensing: Apache-2.0 for code, CC BY-NC-ND 4.0 for images
