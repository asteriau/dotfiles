{ pkgs, self, ... }:
let
  flakePkgs = self.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  fonts = {
    packages = with pkgs; [
      material-symbols
      rubik
      nerd-fonts.jetbrains-mono
      twemoji-color-font
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      flakePkgs.google-sans-flex
      flakePkgs.readex-pro
      flakePkgs.space-grotesk
    ];

    fontconfig.subpixel.rgba = "none";
  };
}
