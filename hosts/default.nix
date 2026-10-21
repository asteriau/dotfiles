{ self, inputs, ... }:
{
  flake.nixosConfigurations =
    let
      inherit (inputs.nixpkgs.lib) nixosSystem;
      system = import "${self}/system";

      mkHost =
        host: modules:
        let
          profile = import ./${host}/profile.nix;
          specialArgs = {
            inherit inputs self profile;
          };
        in
        nixosSystem {
          inherit specialArgs;
          modules = modules ++ [
            ./${host}
            {
              home-manager = {
                users.${profile.user}.imports = [ "${self}/home" ];
                extraSpecialArgs = specialArgs;
                backupFileExtension = ".hm-backup";
              };
            }
          ];
        };
    in
    {
      meow = mkHost "meow" (system.desktop ++ system.wayland ++ system.gaming);
    };
}
