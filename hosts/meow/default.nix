{
  pkgs,
  lib,
  profile,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./powersave.nix
    ../../modules/gaming/aagl.nix
  ];

  boot = {
    kernelModules = [
      "i2c-dev"
    ];

    initrd.kernelModules = [
      "nvidia"
      "nvidia_modeset"
      "nvidia_uvm"
      "nvidia_drm"
    ];

    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

    kernelParams = [
      "nvidia_drm.modeset=1"
      "amd_pstate=active"
      "ideapad_laptop.allow_v4_dytc=Y"
      ''acpi_osi="Windows 2020"''
      "amdgpu.dcfeaturemask=0x8"
    ];
  };

  environment.variables.NH_FLAKE = profile.flakePath;

  hardware = {
    # xpadneo.enable = true;
    sensor.iio.enable = true;
  };

  networking.hostName = profile.hostName;

  security.tpm2.enable = true;

  services = {
    # for SSD/NVME
    fstrim.enable = true;

    flatpak.enable = true;
  };
}
