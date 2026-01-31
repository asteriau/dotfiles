{ config, pkgs, ... }:

# Drivers for my gpu are defined here, respectively a GTX 1660.
# If you're on AMD or a older card you'll need to change this.

{
  hardware.graphics.enable = true;

  hardware.nvidia = {
    modesetting.enable = true;
    open = false; # The open driver is unstable
    powerManagement.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
}
