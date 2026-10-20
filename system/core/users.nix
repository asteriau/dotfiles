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
      "networkmanager"
      "video"
      "wheel"
    ];
  };
}
