{
  lib,
  profile,
  ...
}:
{
  # state/ is gitignored — seed the matugen-overlay files that Hyprland and
  # foot source so first boot is silent. Empty hyprland.conf → static colors
  # from settings.nix win; foot.ini → include the preset palette from foot.nix.
  home.activation.quickshellStateDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    state="${profile.flakePath}/home/services/quickshell/state"
    run mkdir -p "$state"
    [ -e "$state/hyprland.conf" ] || run touch "$state/hyprland.conf"
    [ -e "$state/foot.ini" ] || run sh -c 'printf "include = %s/.config/foot/colors.ini\n" "$HOME" > "$1"' _ "$state/foot.ini"
  '';
}
