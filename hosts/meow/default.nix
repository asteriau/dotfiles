{
  pkgs,
  lib,
  profile,
  ...
}:
{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelModules = [ "i2c-dev" ];

    initrd.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];

    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

    kernelParams = [ "nvidia_drm.modeset=1" ];
  };

  environment.variables.NH_FLAKE = profile.flakePath;

  # The panel's preferred mode is 60Hz; hyprland.lua require()s this file.
  home-manager.users.${profile.user}.xdg.configFile."hypr/monitors.lua".text = ''
    hl.monitor({ output = "DP-1", mode = "1920x1080@165", position = "0x0", scale = 1 })
  '';

  networking.hostName = profile.hostName;

  security.tpm2.enable = true;

  services = {
    flatpak.enable = true;
    fstrim.enable = true;
  };
}
