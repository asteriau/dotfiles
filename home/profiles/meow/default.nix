{
  imports = [
    # editors
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
    ../../services/system/tailray.nix
    ../../services/system/udiskie.nix

    # terminal emulators
    ../../terminal/emulators/foot.nix
  ];
}
