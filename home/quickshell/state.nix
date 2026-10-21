{
  lib,
  pkgs,
  profile,
  ...
}:
{
  home.activation.tachyonState = lib.hm.dag.entryAfter [ "writeBoundary" "linkGeneration" ] ''
    # settings app edits this in place; the static Lua in /etc/xdg/hypr require()s it
    overrides="$HOME/.config/hypr/hyprland/shellOverrides/main.lua"
    [ -e "$overrides" ] || run install -Dm644 ${../../system/programs/hyprland/hyprland/shellOverrides/main.lua} "$overrides"
    # matugen writes this on the first wallpaper change; fuzzel.ini includes it
    theme="$HOME/.config/fuzzel/fuzzel_theme.ini"
    [ -e "$theme" ] || run install -Dm644 /dev/null "$theme"
    # shell options whose upstream defaults assume kitty, fish and pacman
    cfg="$HOME/.config/tachyon/config.json"
    [ -e "$cfg" ] || run install -Dm644 ${
      pkgs.writeText "tachyon-config.json" (
        builtins.toJSON {
          apps = {
            terminal = "foot";
            changePassword = "foot --hold fish -i -c passwd";
            update = "foot --hold fish -i -c 'nh os switch ${profile.flakePath}'";
          };
          launcher.pinnedApps = [
            "org.kde.dolphin"
            "foot"
          ];
        }
      )
    } "$cfg"
  '';
}
