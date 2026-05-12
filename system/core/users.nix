{
  pkgs,
  profile,
  ...
}:
{
  users.users.${profile.user} = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "input"
      "libvirtd"
      "networkmanager"
      "plugdev"
      "transmission"
      "video"
      "wheel"
    ];
  };
}
