{
  inputs,
  profile,
  ...
}:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  environment.variables.NH_FLAKE = profile.flakePath;

  networking.hostName = profile.hostName;

  wsl = {
    enable = true;
    defaultUser = profile.user;
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
