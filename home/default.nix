{
  inputs,
  profile,
  ...
}:
{
  imports = [
    ./terminal
    inputs.nix-index-db.homeModules.nix-index
    inputs.tailray.homeManagerModules.default
  ];

  home = {
    username = profile.user;
    homeDirectory = "/home/${profile.user}";
    stateVersion = "23.11";
    extraOutputsToInstall = [
      "doc"
      "devdoc"
    ];
  };

  # disable manuals as nmd fails to build often
  manual = {
    html.enable = false;
    json.enable = false;
    manpages.enable = false;
  };

  # let HM manage itself when in standalone mode
  programs.home-manager.enable = true;

  # Auto start/stop/restart user services on activation instead of just
  # printing suggestions — new services come up without a manual
  # `systemctl --user start ...` on first switch.
  systemd.user.startServices = "sd-switch";
}
