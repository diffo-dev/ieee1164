# SPDX-FileCopyrightText: 2026 diffo-dev
# SPDX-License-Identifier: Apache-2.0

defmodule Ieee1164.MixProject do
  use Mix.Project

  def project do
    [
      app: :ieee1164,
      version: "0.2.0",
      elixir: "~> 1.18",
      description:
        "Knowledge about IEEE 1164 — the nine-value logic standard at the heart of VHDL simulation.",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      usage_rules: usage_rules()
    ]
  end

  defp usage_rules do
    # Example for those using claude.
    [
      file: "CLAUDE.md",
      # rules to include directly in CLAUDE.md
      usage_rules: ["usage_rules:all"],
      skills: [
        location: ".claude/skills",
        # build skills that combine multiple usage rules
        build: [
          artefactory: [
            description:
              "Use this skill working when working with Artefact or Artefactory (doing Artefacture)",
            usage_rules: [:artefact]
          ]
        ]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:usage_rules, "~> 1.0", only: [:dev]},
      {:nx, "~> 0.9"},
      {:artefact_kino, "~> 0.3"},
      {:artefact, "~> 0.3"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:igniter, "~> 0.6", only: [:dev, :test]},
      {:resvg, "~> 0.5.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      name: "ieee1164",
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/diffo-dev/ieee1164",
        "HexDocs" => "https://hexdocs.pm/ieee1164"
      },
      files: ~w(lib priv/diffo/ieee1164 images docs
                mix.exs README.md CHANGELOG.md NOTICE.md LICENSES)
    ]
  end

  defp docs do
    [
      main: "readme",
      assets: %{"images" => "images"},
      extras: [
        "README.md": [title: "README"],
        "CHANGELOG.md": [title: "Changelog"],
        "NOTICE.md": [title: "Notice"],
        "docs/mix_tasks.md": [title: "Mix Tasks"],
        "docs/backgrounds.md": [title: "Print Specifications"]
      ],
      groups_for_extras: [
        Guides: ["docs/mix_tasks.md", "docs/backgrounds.md"]
      ]
    ]
  end
end
