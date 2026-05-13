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
      docs: docs(),
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
                description: "Use this skill working when working with Artefact or Artefactory (doing Artefacture)",
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
      {:artefact_kino, "~> 0.3"},
      {:artefact, "~> 0.3"},
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
