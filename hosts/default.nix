{
  self,
  inputs,
  ...
}:
{
  flake.nixosConfigurations =
    let
      inherit (inputs.nixpkgs) lib;
      inherit (lib) nixosSystem;

      homeImports = import "${self}/home/profiles";

      mod = "${self}/system";
      inherit (import mod)
        laptop
        gaming
        wayland
        wsl
        ;

      mkHost =
        host: extraModules:
        let
          profile = import ./${host}/profile.nix;
          asteriaLib = import "${self}/lib" { inherit lib self profile; };
          specialArgs = {
            inherit inputs self profile;
          }
          // asteriaLib;
        in
        nixosSystem {
          inherit specialArgs;
          modules = extraModules ++ [
            ./${host}
            {
              home-manager = {
                users.${profile.user}.imports = homeImports."${profile.user}@${host}" or homeImports.server;
                extraSpecialArgs = specialArgs;
                backupFileExtension = ".hm-backup";
              };
            }
          ];
        };
    in
    {
      meow = mkHost "meow" (laptop ++ wayland ++ gaming);

      nixos = mkHost "wsl" wsl;
    };
}
