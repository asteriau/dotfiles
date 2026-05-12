{
  pkgs,
  inputs,
  lib,
  config,
  profile,
  quickshell,
  QML2_IMPORT_PATH,
  ...
}:
let
  termColorsPython = pkgs.python3.withPackages (p: [
    p.materialyoucolor
    p.pillow
  ]);

  dependencies = [
    termColorsPython
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
    gnugrep
    grim
    hyprsunset
    imagemagick
    jq
    libnotify
    networkmanager
    playerctl
    procps
    pulseaudio
    slurp
    wf-recorder
    wireplumber
    wl-clipboard
  ]);
in
{
  imports = [
    ./package.nix
  ];

  home.file.".config/quickshell".source =
    config.lib.file.mkOutOfStoreSymlink "${profile.flakePath}/home/services/quickshell";

  # state/ is gitignored — seed the matugen-overlay files that Hyprland and
  # foot source so first boot is silent. Empty hyprland.conf → static colors
  # from settings.nix win; foot.ini → include the preset palette from foot.nix.
  home.activation.quickshellStateDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    state="${profile.flakePath}/home/services/quickshell/state"
    run mkdir -p "$state"
    [ -e "$state/hyprland.conf" ] || run touch "$state/hyprland.conf"
    [ -e "$state/foot.ini" ] || run sh -c 'printf "include = %s/.config/foot/colors.ini\n" "$HOME" > "$1"' _ "$state/foot.ini"
  '';

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
      Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath dependencies}:${config.home.homeDirectory}/.nix-profile/bin:/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin QML2_IMPORT_PATH=${QML2_IMPORT_PATH}";
      ExecStart = lib.getExe quickshell;
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # populates clipboard history that the quickshell launcher reads
  systemd.user.services.cliphist = {
    Unit = {
      Description = "Clipboard history watcher";
      PartOf = [ "graphical-session.target" ];
      After = "graphical-session.target";
    };
    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
