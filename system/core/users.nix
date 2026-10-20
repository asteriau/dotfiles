{
  pkgs,
  profile,
  ...
}:
{
  users.users.${profile.user} = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = [
      "input"
      "networkmanager"
      "video"
      "wheel"
    ];
  };
}
