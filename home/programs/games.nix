{ inputs, pkgs, ... }:
{
  home.packages = with pkgs; [
    # default latency sometimes crackles
    (inputs.nix-gaming.packages.${stdenv.hostPlatform.system}.osu-lazer-bin.override {
      pipewire_latency = "128/48000";
    })
    prismlauncher
    protontricks
    wineWow64Packages.wayland
    winetricks
  ];
}
