{
  lib,
  profile,
  ...
}:
{
  # state/ is gitignored — seed the overlay files that Hyprland and foot load
  # so first boot is silent. hyprland-colors.lua is dofile'd by colors.lua
  # (a valid no-op until Theme.qml/Matugen.qml populate it); foot.ini → include
  # the preset palette from foot.nix.
  home.activation.quickshellStateDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    state="${profile.flakePath}/home/services/quickshell/state"
    run mkdir -p "$state"
    [ -e "$state/hyprland-colors.lua" ] || run sh -c 'printf "%s\n" "-- seeded; populated by Theme.qml (preset) / Matugen.qml (matugen)" > "$1"' _ "$state/hyprland-colors.lua"
    [ -e "$state/foot.ini" ] || run sh -c 'printf "include = %s/.config/foot/colors.ini\n" "$HOME" > "$1"' _ "$state/foot.ini"
  '';
}
