{ pkgs, config, ... }:
{

  hardware.opentabletdriver = {
    enable = true;
    daemon.enable = true;
  };

}
