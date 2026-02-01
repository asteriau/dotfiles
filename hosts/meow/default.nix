{
  pkgs,
  self,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./powersave.nix
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

  # nh default flake
  environment.variables.NH_FLAKE = "/home/laura/Documents/code/dotfiles";

  hardware = {
    # xpadneo.enable = true;
    sensor.iio.enable = true;
  };

  networking.hostName = "meow";

  security.tpm2.enable = true;

  services = {
    # for SSD/NVME
    fstrim.enable = true;

    howdy = {
      enable = true;
      control = "sufficient";
      settings = {
        core = {
          no_confirmation = true;
          abort_if_ssh = true;
        };
        video.dark_threshold = 90;
      };
    };

    linux-enable-ir-emitter.enable = true;

  };

  security.pam.services."sshd".howdy.enable = false;
}
