{
  imports = [
    # editors
    ../../editors/helix
    ../../editors/vscode

    # programs
    ../../programs
    ../../programs/games
    ../../programs/wayland

    # services
    ../../services/quickshell

    # media services
    ../../services/media/playerctl.nix
    ../../services/media/spotify.nix

    # system services
    ../../services/system/kdeconnect.nix
    ../../services/system/polkit-agent.nix
    ../../services/system/syncthing.nix
    ../../services/system/tailray.nix
    ../../services/system/theme.nix
    ../../services/system/udiskie.nix

    # wayland-specific
    ../../services/wayland/gammastep.nix
    ../../services/wayland/hyprpaper.nix

    # terminal emulators
    ../../terminal/emulators/foot.nix
    ../../terminal/emulators/wezterm.nix
    ../../terminal/emulators/kitty.nix
  ];

}
