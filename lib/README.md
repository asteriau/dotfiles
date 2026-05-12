# Lib

Helpers injected into every module via `specialArgs` (see `hosts/default.nix`):

| Name       | Description                                                     |
| ---------- | --------------------------------------------------------------- |
| `colors`   | Low-level color helpers (`x`, `rgba`, `hexToDec`, `xcolors`, …) |
| `theme`    | Palette + format helpers; reads `themes/*.json` presets         |
| `repl.nix` | Nix REPL wrapper, exported as a flake package                   |
