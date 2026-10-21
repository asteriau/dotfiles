{ config, ... }:
let
  inherit (config.xdg) cacheHome configHome dataHome;
in
{
  imports = [
    ./cli.nix
    ./git.nix
    ./nix.nix
    ./yazi.nix
  ];

  home.sessionVariables = {
    LESSHISTFILE = "${cacheHome}/less/history";
    LESSKEY = "${configHome}/less/lesskey";
    WINEPREFIX = "${dataHome}/wine";
    DIRENV_LOG_FORMAT = "";
    # run uninstalled commands through nix-index-database
    NIX_AUTO_RUN = "1";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
    "$HOME/.opencode/bin"
  ];
}
