{ inputs, ... }:
{
  imports = [
    inputs.git-hooks.flakeModule
    inputs.treefmt-nix.flakeModule
  ];

  perSystem = {
    pre-commit.settings = {
      excludes = [ "flake.lock" ];
      hooks.treefmt.enable = true;
    };

    # vendored upstream trees and theme assets, must stay byte-identical
    treefmt.settings.global.excludes = [
      "home/quickshell/tachyon/**"
      "home/quickshell/matugen/templates/**"
      "system/programs/hyprland/hyprland.lua"
      "system/programs/hyprland/hyprland/**"
      "home/programs/Kvantum/**"
      "home/programs/icons/**"
    ];

    treefmt.programs = {
      nixfmt.enable = true;

      prettier = {
        enable = true;
        excludes = [
          "*.js"
          "*.md"
          "*.ts"
        ];
      };
    };
  };
}
