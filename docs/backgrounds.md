<!--
SPDX-FileCopyrightText: 2026 diffo-dev
SPDX-License-Identifier: Apache-2.0
-->

# std_logic_1164 glyph — Print Specifications

Pantone references are Pantone Matching System (PMS) Coated (C) unless noted.
Fluorescent inks (802 C, 812 C) require specialist screen printing — confirm with printer.

---

## Green Phosphor (green shirt)

Monochrome — **one print colour** on fabric.

| Element        | Hex       | Pantone        | Notes                        |
|----------------|-----------|----------------|------------------------------|
| Garment        | `#1a5c0a` | **357 C**      | Dark forest green fabric     |
| Phosphor print | `#39ff14` | **802 C**      | Fluorescent green ink        |

All design elements (headers, rule regions, crosshatch) print in **802 C** at varying
densities/halftone. The mirror triangle uses a coarse grid halftone at ~40% density.

---

## Hercules Amber (orange shirt)

Monochrome — **one print colour** on fabric.

| Element        | Hex       | Pantone        | Notes                          |
|----------------|-----------|----------------|--------------------------------|
| Garment        | `#b84400` | **1525 C**     | Burnt orange fabric            |
| Phosphor print | `#FFB000` | **1235 C**     | Warm amber/gold ink            |

Alternate amber: **137 C** (slightly deeper orange push). Confirm against physical swatch.
All design elements print in **1235 C** at varying densities.

---

## X11 1993 (MidnightBlue shirt)

Multi-colour — **8 print colours** on fabric.

| Element               | Hex       | X11 Name        | Pantone        |
|-----------------------|-----------|-----------------|----------------|
| Garment               | `#191970` | MidnightBlue    | **2747 C**     |
| Header / text         | `#ffffff` | White           | **White**      |
| Mirror triangle       | `#ffffff` | White           | **White**      |
| Self (diagonal)       | `#000000` | Black           | **Black C**    |
| U propagates          | `#B22222` | Firebrick       | **1805 C**     |
| forces                | `#4169E1` | RoyalBlue       | **2727 C**     |
| conflicts             | `#708090` | SlateGray       | **5425 C**     |
| Z yielding            | `#3CB371` | MediumSeaGreen  | **360 C**      |
| weakly forces         | `#FF69B4` | HotPink         | **812 C**      |
| − poisons             | `#8B0000` | DarkRed         | **1815 C**     |

Note: **812 C** is fluorescent. Substitute **218 C** if fluorescent ink unavailable.

---

## Geek Black (black shirt)

Multi-colour — **7 print colours** on fabric.

| Element               | Hex       | Pantone        | Notes                          |
|-----------------------|-----------|----------------|--------------------------------|
| Garment               | `#111111` | **Black C**    | Black fabric                   |
| Header / text         | `#ffffff` | **White**      |                                |
| Mirror triangle       | `#ffffff` | **White**      |                                |
| Self (diagonal)       | `#000000` | **Black C**    |                                |
| U propagates          | `#cc4400` | **1525 C**     | Burnt orange                   |
| forces                | `#1a5ca8` | **285 C**      | Process blue                   |
| conflicts             | `#555555` | **424 C**      | Mid grey                       |
| Z yielding            | `#228844` | **356 C**      | Forest green                   |
| weakly forces         | `#c03070` | **226 C**      | Magenta-pink                   |
| − poisons             | `#8b0000` | **1815 C**     | Dark red                       |

---

## General Print Notes

- All designs are supplied as SVG (vector) — scale to any garment size without loss.
- Recommended print method: **screen printing** for best colour accuracy and durability.
- DTG (direct-to-garment) is acceptable for samples; colours may vary on dark fabrics.
- For phosphor designs, the coarse crosshatch mirror region (8px grid) must be reproduced
  faithfully — confirm halftone ruling with printer before production run.
- The `std_logic_1164` empty file in `images/` is a placeholder — ignore.

