{ config, ... }:
let
  conf = config.xdg.configHome;
  cache = config.xdg.cacheHome;
in
{
  imports = [
    ./programs
    ./shell
  ];

  home.sessionVariables = {
    LESSHISTFILE = "${cache}/less/history";
    LESSKEY = "${conf}/less/lesskey";
    EDITOR = "hx";
    DIRENV_LOG_FORMAT = "";
  };
}
