# SPDX-FileCopyrightText: 2026 diffo-dev
# SPDX-License-Identifier: Apache-2.0

defmodule Mix.Tasks.Ieee1164.GenPngs do
  use Mix.Task

  @shortdoc "Render each glyph SVG to a shareable PNG"

  @moduledoc """
  Rasterises every `images/glyphs/*.svg` to a PNG beside it, for places where
  SVG shares as text rather than an image (Discord, WhatsApp). The SVGs stay
  the source of truth; the PNGs are generated and git-ignored.

      mix ieee1164.gen_pngs

  Uses resvg (a dev-only dependency). Pass `--zoom` to change the output
  resolution — the SVGs are 560px wide, so the default of 2 renders at 1120px:

      mix ieee1164.gen_pngs --zoom 3
  """

  @glyph_dir "images/glyphs"

  @impl Mix.Task
  def run(args) do
    unless Code.ensure_loaded?(Resvg) do
      Mix.raise("ieee1164.gen_pngs needs the dev dependency resvg — run with MIX_ENV=dev.")
    end

    {opts, _, _} = OptionParser.parse(args, strict: [zoom: :float])
    zoom = opts[:zoom] || 2.0

    case Path.wildcard(Path.join(@glyph_dir, "*.svg")) do
      [] ->
        Mix.shell().info("No SVGs found in #{@glyph_dir}")

      svgs ->
        for svg <- svgs do
          png = Path.rootname(svg) <> ".png"
          # resvg requires the destination not to exist.
          File.rm(png)

          # Via apply/3 so dev-only resvg doesn't trip an "undefined"
          # warning when this task is compiled in :test or :prod.
          case apply(Resvg, :svg_to_png, [svg, png, [zoom: zoom]]) do
            :ok -> Mix.shell().info("  #{Path.basename(png)}")
            {:error, reason} -> Mix.raise("#{Path.basename(svg)}: #{reason}")
          end
        end

        Mix.shell().info("#{length(svgs)} glyphs rendered to #{@glyph_dir}/ (zoom #{zoom})")
    end
  end
end
