{ pkgs, self, ... }:
let
  ii = self.packages.${pkgs.stdenv.hostPlatform.system};
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
      ii.google-sans-flex
      ii.readex-pro
      ii.space-grotesk
    ];

    enableDefaultPackages = false;

    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Rubik" ];
      monospace = [ "JetBrainsMono Nerd Font" ];
      emoji = [ "Noto Color Emoji" ];
    };
  };
}
