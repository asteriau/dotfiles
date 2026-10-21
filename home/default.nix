{ inputs, profile, ... }:
{
  imports = [
    ./quickshell
    ./programs
    ./terminal
    inputs.nix-index-db.homeModules.nix-index
    inputs.tailray.homeManagerModules.default
  ];

  home = {
    username = profile.user;
    homeDirectory = "/home/${profile.user}";
    stateVersion = "23.11";
  };

  # nmd fails to build often
  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false;
  };

  programs.home-manager.enable = true;

  # start/stop/restart user services on activation
  systemd.user.startServices = "sd-switch";
}
