{ lib, ... }:
{
  xdg.configFile = {
    "hypr/hypridle.conf".source = ./hypridle.conf;
    "hypr/hyprlock/status.sh".source = ./hyprlock/status.sh;
    "hypr/hyprlock/check-capslock.sh".source = ./hyprlock/check-capslock.sh;
  };

  # hyprlock.conf is edited in place by the settings app (12h clock toggle) and
  # colors.conf is rewritten by matugen, so both are seeded, not linked.
  home.activation.hyprlockSeed = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    [ -e "$HOME/.config/hypr/hyprlock.conf" ] || run install -Dm644 ${./hyprlock.conf} "$HOME/.config/hypr/hyprlock.conf"
    [ -e "$HOME/.config/hypr/hyprlock/colors.conf" ] || run install -Dm644 ${./hyprlock/colors.conf} "$HOME/.config/hypr/hyprlock/colors.conf"
  '';
}
