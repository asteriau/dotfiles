{
  theme = {
    wallpaper =
      let
        url = "https://github.com/asteriau/dotfiles/blob/main/assets/wallpapers/evening-sky.png?raw=true";
        sha256 = "7d8333a18dee9f8a863924780cca955001661868a5fb05337b7d6b2cbae37007";
        ext = "png";
      in
      builtins.fetchurl {
        name = "wallpaper-${sha256}.${ext}";
        inherit url sha256;
      };
  };
}
