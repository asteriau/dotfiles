{ pkgs, ... }:
{
  # Binaries the shell, its scripts and the Hyprland config call by name,
  # grouped like upstream's sdata/dist-arch metapackages.
  _module.args.quickshellDeps = with pkgs; [
    # audio
    cava
    lxqt.pavucontrol-qt
    playerctl
    easyeffects
    ffmpeg # ffplay for Audio.qml system sounds
    wireplumber # wpctl

    # backlight
    brightnessctl
    ddcutil

    # basic
    bash
    bc
    coreutils
    cliphist
    curl
    wget
    jq
    gnugrep
    gnused
    findutils
    procps
    psmisc # killall
    file
    util-linux # lscpu
    xdg-user-dirs
    xdg-utils

    # hyprland
    hyprsunset
    wl-clipboard
    hypridle
    hyprlock
    hyprpicker
    nwg-displays
    libnotify

    # kde kcms the shell opens
    kdePackages.bluedevil
    kdePackages.plasma-nm
    kdePackages.kdialog
    kdePackages.kconfig # kwriteconfig6
    kdePackages.kcmutils # kcmshell6

    # screencapture
    pulseaudio # pactl, record.sh audio source
    hyprshot
    slurp
    swappy
    grim
    wf-recorder
    (tesseract.override { enableLanguages = [ "eng" ]; })

    # toolkit
    upower
    wtype
    ydotool

    # widgets
    mpvpaper # video wallpapers
    fuzzel
    glib # gsettings
    imagemagick
    songrec
    translate-shell
    wlogout
    libqalculate # qalc
    matugen

    # keyring (scripts/keyring/*.sh, KeyringStorage.qml)
    libsecret # secret-tool

    # network
    networkmanager # nmcli
  ];
}
