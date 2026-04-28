# Themes

Hand-authored color presets that the shell can load at runtime.

Each file in this directory is a flat JSON object whose keys map 1:1 to the
base palette consumed by `utils/Colors.qml` (via `utils/Theme.qml`). Derived
tokens — hover overlays, shadows, accent variants, workspace glow, etc. —
are computed from these base values inside `Colors.qml` and must not appear
in presets.

## Selecting a preset

In the **Settings → Theme** page:

1. Set *Theme source* to **Preset**.
2. Pick a preset (or type its basename — without the `.json` — into the
   *Preset name* field).

The shell auto-reloads when the preset file is modified.

## Sharing a preset

Drop a `<name>.json` file into this directory. It will show up in the
Settings picker after a brief moment. To share, just send someone the
JSON file — they drop it into their own `~/.config/quickshell/themes/`.

## Schema

All 22 keys are required. Values are any CSS-style color string that QML
accepts (`#RRGGBB`, `#AARRGGBB`, named colors, `rgba(…)`).

```json
{
  "background":              "#151515",
  "foreground":              "#E8E3E3",
  "elevated":                "#1E1E1E",
  "border":                  "#252525",
  "accent":                  "#8DA3B9",
  "red":                     "#B66467",
  "mpris":                   "#8C977D",

  "surfaceContainerLowest":  "#0F1012",
  "surfaceContainerLow":     "#1A1D21",
  "surfaceContainer":        "#1E2226",
  "surfaceContainerHigh":    "#282D32",
  "surfaceContainerHighest": "#333940",

  "primaryContainer":        "#253240",
  "m3onPrimary":             "#1A2530",
  "m3onPrimaryContainer":    "#B5C8D8",

  "secondaryContainer":      "#3A4249",
  "m3onSecondaryContainer":  "#DAE2EA",

  "accentContainer":         "#263545",
  "accentText":              "#151520",
  "accentContainerText":     "#C8D6E3",

  "m3onSurfaceVariant":      "#B0B8C0",
  "m3outline":               "#7A8590"
}
```

Missing keys fall back to the built-in default-dark value and warn once
in the Quickshell log.

## Tip: derive a preset from matugen

Run matugen once (see `../matugen/README.md`), then copy
`~/.config/quickshell/state/colors.json` into this directory under a
meaningful name. Edit by hand, commit, share.
