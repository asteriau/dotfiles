{ config, ... }:
{
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    setSessionVariables = true;
    extraConfig.SCREENSHOTS = "${config.xdg.userDirs.pictures}/Screenshots";
  };
}
