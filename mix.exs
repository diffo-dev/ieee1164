# SPDX-FileCopyrightText: 2026 diffo-dev contributors
# SPDX-License-Identifier: Apache-2.0

defmodule Ieee1164.MixProject do
  use Mix.Project

  def project do
    [
      app: :ieee1164,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:artefact_kino, "~> 0.2"},
      #{:artefact, "~> 0.2.1"}, # on https://github.com/diffo-dev/artefactory/issues/38
      {:artefact, path: "../artefactory/artefact", override: true},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:igniter, "~> 0.6", only: [:dev, :test]}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: [
        "README.md": [title: "README"],
        "docs/mix_tasks.md": [title: "Mix Tasks"],
        "docs/backgrounds.md": [title: "Print Specifications"]
      ],
      groups_for_extras: [
        Guides: ["docs/mix_tasks.md", "docs/backgrounds.md"]
      ]
    ]
  end
end
