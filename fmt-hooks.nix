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

    # vendored upstream trees and conf files, must stay byte-identical
    treefmt.settings.global.excludes = [
      "home/quickshell/ii/**"
      "home/quickshell/matugen/**"
      "system/programs/hyprland/hyprland.lua"
      "system/programs/hyprland/hyprland/**"
      "home/programs/wlogout/**"
      "home/programs/Kvantum/**"
      "home/programs/hyprlock/**"
      "home/programs/seed/**"
      "home/programs/hypridle.conf"
      "home/programs/hyprlock.conf"
      "home/programs/kde-material-you-colors.conf"
      "home/programs/fonts.conf"
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
