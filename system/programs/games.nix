{ pkgs, ... }:
{
  programs = {
    gamemode = {
      enable = true;
      settings.general = {
        softrealtime = "auto";
        renice = 15;
      };
    };

    gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--rt"
        "--expose-wayland"
      ];
    };

    steam = {
      enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      gamescopeSession.enable = true;
    };
  };
}
