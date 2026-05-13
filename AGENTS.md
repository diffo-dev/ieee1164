# AGENTS.md — Guide for Future Maintainers

This file is for anyone — human or otherwise — who picks up this repository and wants to understand it, extend it, or fix something without breaking what it holds.

---

## What this is

`ieee1164` is a knowledge package about IEEE Std 1164-1993 — the nine-value logic standard that underpins VHDL simulation. It is part of the diffo project, which is about knowing knowledge: valuing it, being with it, and doing with it in right relationship.

The knowledge here is not just information. It is expressed as _yarn_ — a structured narrative that allows IEEE 1164 to tell its own story, one chapter at a time. The yarn is compiled into `%Artefact{}` structures (from the `artefact` library) that carry both the knowledge graph and the narrative from which it came.

The primary deliverables are:

- **`lib/diffo/ieee1164.ex`** — the yarn and the compiled artefact API
- **`livebook/ieee1164_yarn.livemd`** — an interactive yarn journey, one chapter at a time
- **`livebook/knowing_std_logic_1164.livemd`** — a deeper livebook structured around valuing, being, knowing, and doing
- **`images/glyphs/`** — SVG glyphs memorialising the resolution matrix, each representing an era of knowing

---

## Repository layout

```
lib/
  diffo/
    ieee1164.ex               ← yarn sections + stream functions
    ieee1164/
      parser.ex               ← Cypher-style yarn → Artefact parser
  mix/tasks/
    ieee1164.compile.ex       ← compiles yarn to .bin files
    ieee1164.gen_uuids.ex     ← assigns stable UUIDv7s to nodes

priv/diffo/ieee1164/
  uuids.exs                   ← stable node identities (committed)
  *.bin                       ← compiled artefact binaries (committed)
  ieee1164.txt                ← raw yarn source
  ieee_vasg/                  ← upstream VHDL source (read-only reference)

livebook/
  ieee1164_yarn.livemd        ← the yarn journey livebook
  knowing_std_logic_1164.livemd ← the knowing livebook

images/glyphs/
  std_logic_1164_black.svg           ← Dark Mode glyph (memorial)
  std_logic_1164_black_key.svg       ← Dark Mode with resolution rule key (explanatory)
  std_logic_1164_green_phosphor.svg  ← Green Phosphor era
  std_logic_1164_hercules.svg        ← Hercules Amber era
  std_logic_1164_x11.svg             ← X11 era
  std_logic_1164_unknown.svg         ← pre-journey glyph (grey, values hidden)
  std_logic_1164_matrix.svg          ← values visible, meaning not yet known

docs/
  mix_tasks.md                ← Mix task documentation
  backgrounds.md              ← print specifications for the glyphs (T-shirts)

LICENSES/
  Apache-2.0.txt              ← code licence
  CC-BY-NC-ND-4.0.txt         ← image licence
REUSE.toml                    ← SPDX file-level licence declarations
NOTICE                        ← combined licence notice
```

---

## The yarn pattern

The yarn in `lib/diffo/ieee1164.ex` is a series of module attributes, each holding a Cypher-style string:

```elixir
@signals ~S|
  (SIGNAL:{name: "std_ulogic"}) - [RESOLVES_TO] -> (SIGNAL:{name: "std_logic"})
  ...
|
```

Each section is parsed by `Diffo.Ieee1164.Parser` into a `%Artefact{}` with nodes and relationships. Sections accumulate — each new one is combined with all previous sections to form a growing integrated artefact.

The two key stream functions are:

- `Diffo.Ieee1164.stream/0` — returns each section as its own standalone artefact
- `Diffo.Ieee1164.stream_integrated/0` — returns each section as a cumulative artefact, growing chapter by chapter

Both return lazy `Stream`s. In a livebook you call `Enum.to_list/1` on them. The final element of `stream_integrated` is the complete IEEE 1164 knowledge graph.

**Adding a new section:** Add a module attribute with the yarn, add the key to the `@sections` list, and run the build pipeline. The title of each integrated artefact is set in `stream_integrated` using struct update syntax: `%{artefact | title: "..."}`.

---

## Build pipeline

Run in order whenever the yarn changes:

```sh
mix ieee1164.gen_uuids   # assigns UUIDv7 to any new node names
mix ieee1164.compile     # parses yarn → .bin files in priv/
```

Commit both `priv/diffo/ieee1164/uuids.exs` and the `.bin` files. Livebooks and runtime consumers load from `.bin` — they do not re-parse the yarn.

---

## Testing

```sh
mix test                          # standard suite (no prior build required)
mix ieee1164.gen_uuids
mix ieee1164.compile
mix test --include integration    # includes compile task tests
```

---

## The livebooks

Both livebooks use `Mix.install` with a local path dependency:

```elixir
Mix.install([
  {:ieee1164, path: "/Users/beanlanda/git/ieee1164", override: true},
  {:kino, "~> 0.13"}
])
```

The path is absolute and will need updating if the repo moves. `artefact_kino` is a transitive dependency of `ieee1164` and does not need to be listed explicitly in `Mix.install`.

### Interactive button pattern in Livebook

The only reliable pattern for interactive buttons in Livebook is `Task.start` + `Kino.Control.stream`. Do not use `Kino.listen` (its listener process is tied to the evaluator and dies with it). Do not merge streams with origin matching (button struct comparison is unreliable). The pattern is:

```elixir
button = Kino.Control.button("Label")
frame  = Kino.Frame.new()

# Kill any previous listener from a prior cell evaluation
if pid = Process.whereis(:my_listener), do: Process.exit(pid, :kill)

{:ok, pid} = Task.start(fn ->
  Kino.Control.stream(button)
  |> Enum.each(fn _click ->
    Kino.Frame.render(frame, some_kino)
  end)
end)

Process.register(pid, :my_listener)
Kino.Layout.grid([button, frame], columns: 1)
```

When you have multiple buttons that each need different behaviour, start one task per button and close over its data in the closure — do not use `Kino.Control.merge` with `origin` matching.

For named process registration with multiple buttons use atoms like `:"my_listener_0"`, `:"my_listener_1"` etc. and kill them in a loop before re-registering.

### Kino.Download

In Kino 0.19+, `Kino.Download.new/2` accepts only `filename:` and `label:` as options. The callback must return the binary content directly:

```elixir
Kino.Download.new(fn -> svg_binary end, filename: "file.svg", label: "Download")
```

### Heredoc vs sigil for HTML with CSS

When embedding HTML with CSS `transform-origin:` inside Elixir code, use a `"""` heredoc rather than a `~s(...)` sigil. The Elixir tokenizer treats `origin:` as an atom keyword inside `~s()`, causing a `SyntaxError`.

---

## The glyphs

The SVG glyphs in `images/glyphs/` are the primary visual artefacts of this project. They are not decorative — they are memorials.

**Design constraint:** New glyphs must be derived from an existing glyph file, not generated from scratch. The design language (cell sizes, label positions, header text, footer attribution) must be consistent with the existing set. This honours the intentionality of the original design.

**The glyph family:**

| File | Purpose |
|---|---|
| `std_logic_1164_unknown.svg` | Pre-journey: all cells grey, values hidden |
| `std_logic_1164_matrix.svg` | Values visible but meaning not yet understood |
| `std_logic_1164_black_key.svg` | Instructional: values + resolution rule key |
| `std_logic_1164_black.svg` | Memorial: regions only, values absent |
| `std_logic_1164_green_phosphor.svg` | Memorial: green phosphor era |
| `std_logic_1164_hercules.svg` | Memorial: Hercules Amber era |
| `std_logic_1164_x11.svg` | Memorial: X11 era |

The memorial glyphs deliberately omit the cell values. The shape alone carries the knowledge — the viewer must have made the journey to read it.

**Metadata:** Every SVG must have a complete RDF/DC/CC metadata block with `dc:title`, `dc:description`, `dc:rights`, and a `cc:License` block declaring CC BY-NC-ND 4.0 (permits reproduction and distribution; requires notice and attribution; prohibits commercial use and derivative works). See any existing glyph for the template.

**Print specifications:** `docs/backgrounds.md` contains Pantone references and screen printing notes for each glyph variant. These are for physical T-shirt production and should be kept in sync if glyph colours change.

**Licence:** Glyphs are CC BY-NC-ND 4.0. Code is Apache-2.0. The `REUSE.toml` file declares this at the file level — update it if new files are added. Both licence texts are in `LICENSES/`.

---

## Design intentions to preserve

This project has a considered point of view. When making changes, hold these in mind:

**The yarn is primary.** The knowledge lives in the Cypher-style sections in `ieee1164.ex`. The `.bin` files are derived artefacts. If there is a conflict, the yarn is the truth.

**Knowledge is relational.** The artefact graph is not a lookup table — it is a web of named relationships. New knowledge should be expressed as relationships between named nodes, not as properties added to a single node.

**The journey is the point.** The livebooks are designed to be experienced in order. The yarn livebook advances one chapter at a time because accumulation is how understanding works. Do not collapse the journey into a static display.

**Honour the ancestor.** The upstream VHDL source in `priv/diffo/ieee_vasg/` is read-only reference material. It is there so we can see what IEEE P1076 actually wrote. Do not modify it.

**The glyphs are memorials.** The memorial glyphs omit the values deliberately — the meaning is carried by the reader, not the diagram. Do not add value labels to the memorial glyphs.

---

## Dependencies

| Package | Role |
|---|---|
| `artefact` | The knowledge graph struct and combine operations |
| `artefact_kino` | Kino widget for rendering an `%Artefact{}` in Livebook |
| `ex_doc` | Documentation generation (dev only) |
| `igniter` | Code generation tooling (dev/test only) |

The livebooks also depend on `kino` directly (installed via `Mix.install`).

---

## Agent setup

Before starting work, run:

```sh
mix usage_rules.sync
```

This compiles guidance from dependencies into `CLAUDE.md` and installs package skills into `.claude/skills/`. Neither file is committed to the repo — they are build-time outputs that live only on the local machine.

When `.claude/skills/` is present, read and apply any skills found there before proceeding. The `artefactory` skill in particular covers the `artefact` and `artefact_kino` packages used throughout this codebase.

---

## Open issues at time of writing

- **T-shirt link** — a placeholder comment in `knowing_std_logic_1164.livemd` marks where a purchase link for the glyph T-shirts should go.
- **`std_logic_vector` section** — noted as a future addition; the signals section declares it but a dedicated section expanding its role has not yet been written.

<!-- usage-rules-start -->
<!-- artefact-start -->
## artefact usage
_Arrows JSON ↔ Cypher — knowledge graph fragments made in relationship_

# Rules for working with Artefact

## Installation

The preferred way to add Artefact to a project is via Igniter:

```bash
mix igniter.install artefact
```

This wires up the formatter automatically. If your project does not use Igniter, add the dep manually and run `mix deps.get`.

## What Artefact is

Artefact is an Elixir library for building, combining, and persisting knowledge graph fragments. An `%Artefact{}` is a named, typed property graph — a small, self-contained piece of knowledge. It is not an application data model, a database schema, or a general-purpose graph library.

The intended use is knowledge memorialisation: capturing shared understanding between people, agents, or systems in a form that can be combined, versioned, and persisted.

## require Artefact

`Artefact.new/1`, `Artefact.new!/1`, `Artefact.combine!/2`, and all other operations are **macros**. Always `require Artefact` before calling them:

```elixir
require Artefact

artefact = Artefact.new!(
  title: "Us Two",
  nodes: [
    matt:   [labels: ["Agent"], properties: %{"name" => "Matt"}],
    claude: [labels: ["Agent"], properties: %{"name" => "Claude"}]
  ],
  relationships: [
    [from: :matt, type: "US_TWO", to: :claude]
  ]
)
```

Without `require`, you will get a compile-time error about undefined functions. This is the most common source of confusion when first using Artefact.

## UUID is identity

Every node carries a UUIDv7 `uuid`. This is its identity — the same UUID in two artefacts means the same node. `combine!/2` uses UUID equality to find shared nodes and merge them.

**Never change a UUID once it has been used in a persisted or shared artefact.** If you assign a UUID explicitly at construction time, keep it. If you do not assign one, Artefact generates a time-ordered UUIDv7 automatically.

For importing from external sources — Mermaid diagrams, Cypher files, JSON — derive UUIDs deterministically from a stable identifier using `Artefact.UUID.from_name/1`:

```elixir
uuid = Artefact.UUID.from_name("std_ulogic")
# same name always → same UUID, valid UUIDv7
```

This means the same external id imported twice always produces the same node, and `combine!/2` will bind correctly across imports.

## Operations at a glance

| Operation | What it does | Key constraint |
|---|---|---|
| `new!/1` | Build a fresh artefact | Macro — `require Artefact` |
| `combine!/2` | Union two artefacts via shared UUIDs | Different `base_label` required |
| `harmonise!/3` | Union via explicit bindings | Different `base_label` required |
| `compose!/2` | Concatenate — nodes stay disjoint | No shared UUIDs expected |
| `graft!/2` | Extend an existing artefact inline | Every new node must carry `:uuid` |

Each operation has a `!/n` (raises) and `/n` (returns `{:ok, _} | {:error, _}`) variant.

## combine!/2 requires different base_label values

`combine!/2` finds shared nodes automatically by UUID. It requires the two artefacts to have **different** `base_label` values — this distinguishes "what I know" from "what I am adding":

```elixir
# Raises Artefact.Error.Operation with same_base_label
Artefact.combine!(a, b)  # both default base_label to calling module name

# Correct
a = Artefact.new!(base_label: "Signals", ...)
b = Artefact.new!(base_label: "Values", ...)
combined = Artefact.combine!(a, b)
```

When no `base_label` is set explicitly, it defaults to the short name of the calling module — so two artefacts built in the same module will clash.

## Mermaid import and export

`Artefact.Mermaid.export/2` converts an artefact to a Mermaid `graph` source string. `Artefact.Mermaid.from_mmd!/2` parses it back. The round-trip is lossless for: title, description, node names, labels, and relationship types.

### UUID identity anchors on the Mermaid node id

When importing with `from_mmd!/2`, the UUID of each node is derived from its **Mermaid node id** — the `\w+` identifier (e.g. `val_0`, `std_ulogic`) — not the display label inside the shape. Keep node ids stable across diagram versions; changing an id changes the UUID and breaks bindings.

```mermaid
graph LR
  std_ulogic(("std_ulogic<br/>Signal"))  ← id is std_ulogic, UUID derived from "std_ulogic"
```

### Declare nodes separately from edges for label recovery

When a node's shape is declared inline on an edge line, the label is not captured:

```
val_0["VALUE · 0"] -->|ENUMERATES| value  ← label "VALUE" is lost
```

Use a separate declaration line:

```
graph LR
  val_0["VALUE · 0"]
  val_0 -->|ENUMERATES| value
```

The export format produced by `export/2` always uses separate lines, so this only applies to hand-authored Mermaid.

### Node label conventions in Mermaid

Two formats are recognised inside node shapes:

- `name<br/>Label1 Label2` — our export format
- `LABEL · name` — yarn convention (one label and name separated by ` · `)

### Node descriptions via click tooltips

Node `description` properties are exported as `click id "text"` lines and recovered on import. They are visible as hover tooltips in Mermaid renderers.

## %Artefact{} struct shape

```elixir
%Artefact{
  uuid: "019e...",          # UUIDv7 — the artefact's own identity
  title: "My Artefact",    # optional
  description: "...",      # optional
  base_label: "Concept",   # optional — collapsed into per-node labels at export
  graph: %Artefact.Graph{
    nodes: [
      %Artefact.Node{
        id: "n0",           # internal sequential id — do not rely on this across artefacts
        uuid: "019e...",    # UUIDv7 — stable identity
        labels: ["Concept", "Thing"],
        properties: %{"name" => "Alpha", "description" => "..."}
      }
    ],
    relationships: [
      %Artefact.Relationship{
        id: "r0",           # internal sequential id
        type: "RELATES",    # MACRO_CASE convention
        from_id: "n0",
        to_id: "n1",
        properties: %{}
      }
    ]
  }
}
```

Node `id` values (`n0`, `r0`) are internal and sequential within one artefact. Use `uuid` for stable cross-artefact identity.

<!-- artefact-end -->
<!-- usage_rules-start -->
## usage_rules usage
_A config-driven dev tool for Elixir projects to manage AGENTS.md files and agent skills from dependencies_

## Using Usage Rules

Many packages have usage rules, which you should *thoroughly* consult before taking any
action. These usage rules contain guidelines and rules *directly from the package authors*.
They are your best source of knowledge for making decisions.

## Modules & functions in the current app and dependencies

When looking for docs for modules & functions that are dependencies of the current project,
or for Elixir itself, use `mix usage_rules.docs`

```
# Search a whole module
mix usage_rules.docs Enum

# Search a specific function
mix usage_rules.docs Enum.zip

# Search a specific function & arity
mix usage_rules.docs Enum.zip/1
```


## Searching Documentation

You should also consult the documentation of any tools you are using, early and often. The best 
way to accomplish this is to use the `usage_rules.search_docs` mix task. Once you have
found what you are looking for, use the links in the search results to get more detail. For example:

```
# Search docs for all packages in the current application, including Elixir
mix usage_rules.search_docs Enum.zip

# Search docs for specific packages
mix usage_rules.search_docs Req.get -p req

# Search docs for multi-word queries
mix usage_rules.search_docs "making requests" -p req

# Search only in titles (useful for finding specific functions/modules)
mix usage_rules.search_docs "Enum.zip" --query-by title
```


<!-- usage_rules-end -->
<!-- usage_rules:elixir-start -->
## usage_rules:elixir usage
# Elixir Core Usage Rules

## Pattern Matching
- Use pattern matching over conditional logic when possible
- Prefer to match on function heads instead of using `if`/`else` or `case` in function bodies
- `%{}` matches ANY map, not just empty maps. Use `map_size(map) == 0` guard to check for truly empty maps

## Error Handling
- Use `{:ok, result}` and `{:error, reason}` tuples for operations that can fail
- Avoid raising exceptions for control flow
- Use `with` for chaining operations that return `{:ok, _}` or `{:error, _}`

## Common Mistakes to Avoid
- Elixir has no `return` statement, nor early returns. The last expression in a block is always returned.
- Don't use `Enum` functions on large collections when `Stream` is more appropriate
- Avoid nested `case` statements - refactor to a single `case`, `with` or separate functions
- Don't use `String.to_atom/1` on user input (memory leak risk)
- Lists and enumerables cannot be indexed with brackets. Use pattern matching or `Enum` functions
- Prefer `Enum` functions like `Enum.reduce` over recursion
- When recursion is necessary, prefer to use pattern matching in function heads for base case detection
- Using the process dictionary is typically a sign of unidiomatic code
- Only use macros if explicitly requested
- There are many useful standard library functions, prefer to use them where possible

## Function Design
- Use guard clauses: `when is_binary(name) and byte_size(name) > 0`
- Prefer multiple function clauses over complex conditional logic
- Name functions descriptively: `calculate_total_price/2` not `calc/2`
- Predicate function names should not start with `is` and should end in a question mark.
- Names like `is_thing` should be reserved for guards

## Data Structures
- Use structs over maps when the shape is known: `defstruct [:name, :age]`
- Prefer keyword lists for options: `[timeout: 5000, retries: 3]`
- Use maps for dynamic key-value data
- Prefer to prepend to lists `[new | list]` not `list ++ [new]`

## Mix Tasks

- Use `mix help` to list available mix tasks
- Use `mix help task_name` to get docs for an individual task
- Read the docs and options fully before using tasks

## Testing
- Run tests in a specific file with `mix test test/my_test.exs` and a specific test with the line number `mix test path/to/test.exs:123`
- Limit the number of failed tests with `mix test --max-failures n`
- Use `@tag` to tag specific tests, and `mix test --only tag` to run only those tests
- Use `assert_raise` for testing expected exceptions: `assert_raise ArgumentError, fn -> invalid_function() end`
- Use `mix help test` to for full documentation on running tests

## Debugging

- Use `dbg/1` to print values while debugging. This will display the formatted value and other relevant information in the console.

<!-- usage_rules:elixir-end -->
<!-- usage_rules-start -->
## usage_rules usage
_A config-driven dev tool for Elixir projects to manage AGENTS.md files and agent skills from dependencies_

## Using Usage Rules

Many packages have usage rules, which you should *thoroughly* consult before taking any
action. These usage rules contain guidelines and rules *directly from the package authors*.
They are your best source of knowledge for making decisions.

## Modules & functions in the current app and dependencies

When looking for docs for modules & functions that are dependencies of the current project,
or for Elixir itself, use `mix usage_rules.docs`

```
# Search a whole module
mix usage_rules.docs Enum

# Search a specific function
mix usage_rules.docs Enum.zip

# Search a specific function & arity
mix usage_rules.docs Enum.zip/1
```


## Searching Documentation

You should also consult the documentation of any tools you are using, early and often. The best 
way to accomplish this is to use the `usage_rules.search_docs` mix task. Once you have
found what you are looking for, use the links in the search results to get more detail. For example:

```
# Search docs for all packages in the current application, including Elixir
mix usage_rules.search_docs Enum.zip

# Search docs for specific packages
mix usage_rules.search_docs Req.get -p req

# Search docs for multi-word queries
mix usage_rules.search_docs "making requests" -p req

# Search only in titles (useful for finding specific functions/modules)
mix usage_rules.search_docs "Enum.zip" --query-by title
```


<!-- usage_rules-end -->
<!-- usage_rules:otp-start -->
## usage_rules:otp usage
# OTP Usage Rules

## GenServer Best Practices
- Keep state simple and serializable
- Handle all expected messages explicitly
- Use `handle_continue/2` for post-init work
- Implement proper cleanup in `terminate/2` when necessary

## Process Communication
- Use `GenServer.call/3` for synchronous requests expecting replies
- Use `GenServer.cast/2` for fire-and-forget messages.
- When in doubt, use `call` over `cast`, to ensure back-pressure
- Set appropriate timeouts for `call/3` operations

## Fault Tolerance
- Set up processes such that they can handle crashing and being restarted by supervisors
- Use `:max_restarts` and `:max_seconds` to prevent restart loops

## Task and Async
- Use `Task.Supervisor` for better fault tolerance
- Handle task failures with `Task.yield/2` or `Task.shutdown/2`
- Set appropriate task timeouts
- Use `Task.async_stream/3` for concurrent enumeration with back-pressure

<!-- usage_rules:otp-end -->
<!-- usage-rules-end -->
