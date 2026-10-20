{ lib, ... }:
{
  home.activation.illogicalImpulseState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # settings app edits this in place; the static Lua in /etc/xdg/hypr dofile()s it
    overrides="$HOME/.config/hypr/hyprland/shellOverrides/main.lua"
    [ -e "$overrides" ] || run install -Dm644 ${../../system/programs/hyprland/hyprland/shellOverrides/main.lua} "$overrides"
    # matugen writes this on the first wallpaper change; fuzzel.ini includes it
    theme="$HOME/.config/fuzzel/fuzzel_theme.ini"
    [ -e "$theme" ] || run install -Dm644 /dev/null "$theme"
  '';
}
