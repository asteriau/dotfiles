{
  pkgs,
  inputs,
  lib,
  config,
  ...
}:
let
  quickshell = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;

  dependencies = [
    inputs.matugen.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland
  ]
  ++ (with pkgs; [
    bash
    bluez
    brightnessctl
    cliphist
    coreutils
    curl
    ddcutil
    foot
    gawk
    gnugrep
    grim
    hyprsunset
    jq
    libnotify
    networkmanager
    playerctl
    procps
    pulseaudio
    ripgrep
    slurp
    util-linux
    wf-recorder
    wireplumber
    wl-clipboard
  ]);

  QML2_IMPORT_PATH = lib.concatStringsSep ":" [
    "${quickshell}/lib/qt-6/qml"
    "${pkgs.kdePackages.qtdeclarative}/lib/qt-6/qml"
    "${pkgs.kdePackages.qt5compat}/lib/qt-6/qml"
    "${pkgs.kdePackages.kirigami.unwrapped}/lib/qt-6/qml"
  ];
in
{
  home.packages = [ quickshell ];

  home.file.".config/quickshell".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Documents/Code/dotfiles/home/services/quickshell";

  home.sessionVariables.QML2_IMPORT_PATH = QML2_IMPORT_PATH;

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell";
      PartOf = [
        "tray.target"
        "graphical-session.target"
      ];
      After = "graphical-session.target";
    };
    Service = {
      Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath dependencies} QML2_IMPORT_PATH=${QML2_IMPORT_PATH}";
      ExecStart = lib.getExe quickshell;
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
