{
  imports = [
    # editors
    ../../editors/vscode.nix

    # programs
    ../../programs
    ../../programs/games.nix
    ../../programs/wayland

    # services
    ../../services/quickshell

    # media services
    ../../services/media

    # system services
    ../../services/system

    # terminal emulators
    ../../terminal/emulators/foot.nix
  ];
}
