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

      asteriaLib = import "${self}/lib" { inherit lib self; };

      homeImports = import "${self}/home/profiles";

      mod = "${self}/system";
      inherit (import mod) laptop;

      mkHost =
        host: extraModules:
        let
          profile = import ./${host}/profile.nix;
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
      meow = mkHost "meow" (
        laptop
        ++ [
          "${mod}/programs/gamemode.nix"
          "${mod}/programs/hyprland"
          "${mod}/programs/games.nix"

          "${mod}/network/spotify.nix"

          "${mod}/services/gnome-services.nix"
        ]
      );

      nixos = mkHost "wsl" [
        "${mod}/core/users.nix"
        "${mod}/nix"
        "${mod}/programs/zsh.nix"
        "${mod}/programs/home-manager.nix"
      ];
    };
}
