#!/usr/bin/env bash
#
# Usage:
#   set-theme.sh preset  <name>
#   set-theme.sh matugen <wallpaper> [--scheme=scheme-tonal-spot] [--mode=dark] [--contrast=0.0]
#
# `preset` just verifies the preset exists; set Config.theme.mode=preset and
# Config.theme.preset=<name> in the Settings app (or edit the persisted state).
# `matugen` shells out to matugen with our template/config.

set -euo pipefail

# Resolve the shell source dir from the script's own location. Works whether
# the dotfiles are symlinked at ~/.config/quickshell or kept elsewhere and
# launched via `quickshell --config <path>`.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHELL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
THEMES_DIR="$SHELL_DIR/themes"
STATE_DIR="$SHELL_DIR/state"
RUNTIME_CONFIG="$STATE_DIR/matugen.toml"

usage() {
  cat >&2 <<EOF
Usage:
  $(basename "$0") preset  <name>
  $(basename "$0") matugen <wallpaper> [--scheme=scheme-tonal-spot] [--mode=dark|light] [--contrast=0.0]

Scheme options: scheme-tonal-spot | scheme-vibrant | scheme-expressive |
                scheme-fruit-salad | scheme-rainbow | scheme-neutral |
                scheme-monochrome | scheme-content | scheme-fidelity
EOF
  exit 1
}

sub="${1:-}"
shift || true

case "$sub" in
  preset)
    name="${1:-}"
    [[ -n "$name" ]] || usage
    preset_file="$THEMES_DIR/$name.json"
    if [[ ! -f "$preset_file" ]]; then
      echo "Preset not found: $preset_file" >&2
      exit 1
    fi
    echo "Preset '$name' → $preset_file"
    echo "Set Config.theme.mode=preset and Config.theme.preset=$name in Settings → Theme."
    ;;

  matugen)
    wallpaper="${1:-}"
    [[ -n "$wallpaper" ]] || usage
    shift || true

    scheme="scheme-tonal-spot"
    mode="dark"
    contrast="0"
    for arg in "$@"; do
      case "$arg" in
        --scheme=*)   scheme="${arg#*=}" ;;
        --mode=*)     mode="${arg#*=}"   ;;
        --contrast=*) contrast="${arg#*=}" ;;
        *) echo "Unknown arg: $arg" >&2; usage ;;
      esac
    done

    if ! command -v matugen >/dev/null 2>&1; then
      echo "matugen not found on PATH" >&2
      exit 1
    fi
    if [[ ! -f "$wallpaper" ]]; then
      echo "Wallpaper not found: $wallpaper" >&2
      exit 1
    fi

    mkdir -p "$STATE_DIR"
    # Generate a matugen config with absolute paths resolved from SHELL_DIR.
    # (`[config]` table is required by matugen even when empty.)
    cat > "$RUNTIME_CONFIG" <<EOF
[config]

[templates.quickshell]
input_path  = "$SHELL_DIR/matugen/template.json"
output_path = "$STATE_DIR/colors.json"
EOF

    matugen image "$wallpaper" \
      -m "$mode" \
      -t "$scheme" \
      --contrast "$contrast" \
      --config "$RUNTIME_CONFIG"
    echo "Wrote $STATE_DIR/colors.json"
    ;;

  *) usage ;;
esac
