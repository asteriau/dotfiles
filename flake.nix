{
  description = "illogical-impulse (end-4's dots-hyprland) as a NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default-linux";

    flake-compat.url = "github:edolstra/flake-compat";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs = {
        flake-compat.follows = "flake-compat";
        nixpkgs.follows = "nixpkgs";
      };
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hm = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Not following nixpkgs on purpose: keeps hyprland.cachix.org hits.
    hyprland.url = "github:hyprwm/hyprland";

    # The commit end-4 pins in sdata/dist-arch/illogical-impulse-quickshell-git (v0.3.2).
    quickshell = {
      url = "github:quickshell-mirror/quickshell/4f508be500dea6e5732cc3d50382a0048b17e7b1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    yazi.url = "github:sxyazi/yazi";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [
        ./hosts
        ./pkgs
        ./fmt-hooks.nix
      ];

      perSystem =
        { config, pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            name = "ii";
            packages = [
              pkgs.git
              pkgs.statix
              pkgs.deadnix
              pkgs.nil
              pkgs.treefmt
              pkgs.qt6.qtdeclarative # qmlls for editing home/quickshell/ii
            ];
            env.DIRENV_LOG_FORMAT = "";
            shellHook = config.pre-commit.installationScript;
          };
        };
    };
}
