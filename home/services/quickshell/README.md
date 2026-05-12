# quickshell

Asteria's Quickshell config — bar, sidebar, island, launcher, notifications,
wallpaper picker, settings UI, and screenshot region selector. Material 3
design tokens, matugen-driven palettes with hand-curated preset fallbacks.

## Layout

```
shell.qml                    Entry point. Mounts every panel.
default.nix                  Home Manager wiring.
.qmlformat.ini               Formatter settings.
assets/                      Static images.
matugen/                     Matugen template + Hyprland color stub.
scripts/                     Helper scripts (color generation, recording).
themes/                      Preset palettes (default-dark, default-light).
state/                       Runtime JSON written by the shell (gitignored).
secrets/                     Gitignored.

services/                    Flat backend singletons. Pure logic, no UI.
  Audio Battery BluetoothController Brightness HyprlandActions
  Matugen MprisController Network NightLight Notifications
  NotificationUtils Osd Resources Screenshot SystemInfo Theme
  Weather WindowList

modules/
  common/                    Shared design system + helpers.
    Appearance.qml           ALL design tokens (colors, spacing, radius,
                             font, motion, elevation, sizes). Single
                             source of truth for any UI styling decision.
    Config.qml               ALL persisted user-facing settings. Nested
                             JsonAdapter; `Config.options.<area>.<sub>`.
    Directories.qml          Filesystem path constants.
    UiState.qml              Transient surface-visibility flags.
    Motion.qml               Reusable inline animation components.
    functions/               JS-only utility singletons (ColorUtils,
                             DateUtils, StringUtils, Utils, WorkspaceIcons).
    models/                  Per-instance data structures (no singletons).
    widgets/                 Flat library of reusable UI primitives
                             (Material*, Styled*, Dialog*, Bar*, Content*,
                             RippleButton, PressablePill, IconButton,
                             ResourceDial, etc.).

  background/  bar/  island/  launcher/  notifications/  screenshot/
  settings/    sidebar/ wallpaper/         Feature panels. Each owns its
                                           own subtree of widgets, popups,
                                           and helpers.
```

## Adding a new bar widget

Five steps. Order matters; each step is a single-file change.

1. **Add config** in `modules/common/Config.qml` under the `bar` JsonObject:
    ```qml
    property JsonObject myWidget: JsonObject {
        property bool enable: true
        property int  someKnob: 5
    }
    ```

2. **(Optional) Add a service** if backend data is needed:
   `services/MyService.qml` with the standard
   `Singleton { properties; signals; methods; subscribe?(); }` template.

3. **Create the widget** at `modules/bar/widgets/MyWidget.qml`. Imports
   `qs.modules.common`, `qs.modules.common.widgets`, and `qs.services` if
   the service is needed. Reads `Appearance.*` for styling and
   `Config.options.bar.myWidget.*` for behaviour.

4. **Add to a layout** — append a Loader (gated on
   `Config.options.bar.myWidget.enable`) to `BarLayoutVertical.qml` or
   `BarLayoutHorizontal.qml` in the appropriate zone.

5. **Add settings UI** in `modules/settings/pages/Bar.qml` with a
   `ConfigSwitch` / `ConfigSlider` row bound to `Config.options.bar.myWidget.X`.

## Conventions

- **PascalCase** for QML files, **camelCase** for properties and signals.
- **No magic numbers in UI** — every spacing, radius, color, font size, and
  animation duration comes from `Appearance.*`. Centring math
  (`parent.width / 2`) and the literals `0`, `1`, and small index counts
  are the only allowed bare numbers.
- **Comments answer "why"**, never "what". The filename and code already
  name what; comments only document hidden constraints, workarounds, and
  surprising domain knowledge. No section dividers, no file-top doc blocks
  unless the file's existence itself is non-obvious.
- **Services are pure logic** — they expose properties (read-only state),
  signals (events), and methods (actions). UI files import them via
  `import qs.services` and never embed backend logic.

## Install

`default.nix` symlinks this directory into `~/.config/quickshell` via Home
Manager (`mkOutOfStoreSymlink`) so edits in this repo apply live to the
running shell. Restart with `systemctl --user restart quickshell` after
structural changes.

For matugen theming:

```sh
ln -s $(pwd)/matugen ~/.config/matugen
```
