# SPDX-FileCopyrightText: 2026 diffo-dev
# SPDX-License-Identifier: Apache-2.0

defmodule Mix.Tasks.Ieee1164.Compile do
  use Mix.Task

  @shortdoc "Compile ieee1164 yarn into binary artefacts and write to priv/artefacts/"

  @moduledoc """
  Parses each section of the ieee1164 yarn into an `%Artefact{}` and serialises
  it to `priv/artefacts/<section>.bin` using `:erlang.term_to_binary/1`.

  Also writes the fully combined `ieee1164.bin`.

  Run `mix ieee1164.gen_uuids` only when you add **new nodes** to the yarn;
  it preserves existing UUIDs. `mix ieee1164.compile` is reproducible —
  artefact identity is derived deterministically from section titles, so
  recompiling unchanged yarn yields byte-identical artefacts and only the
  `.bin` files whose section actually changed show up in the diff:

      mix ieee1164.gen_uuids   # only after adding new nodes
      mix ieee1164.compile

  Commit the `.bin` files so livebooks and other consumers can load artefacts
  directly without re-parsing. When a registry or Artefactory service is
  available, this step becomes a push rather than a file write.
  """

  @out "priv/diffo/ieee1164"

  def run(_args) do
    Mix.Task.run("app.start")
    File.mkdir_p!(@out)

    sections = Ieee1164.yarn() |> Enum.map(fn {_, [{key, _}]} -> key end)

    for key <- sections do
      artefact = apply(Ieee1164, key, [])
      path = Path.join(@out, "#{key}.bin")
      File.write!(path, :erlang.term_to_binary(artefact))
      Mix.shell().info("  wrote #{path}")
    end

    combined = Ieee1164.ieee1164()
    path = Path.join(@out, "ieee1164.bin")
    File.write!(path, :erlang.term_to_binary(combined))
    Mix.shell().info("  wrote #{path}")

    Mix.shell().info("#{@out}: #{length(sections) + 1} artefacts compiled")
  end
end
