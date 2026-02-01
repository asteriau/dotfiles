{
  theme = {
    wallpaper =
      let
        url = "https://github.com/asteriau/dotfiles/blob/main/assets/wallpapers/sky.jpg?raw=true";
        sha256 = "7937a4d49b1621d467ae1897fef2767164a69394b12cd31cac747a4dc96f809f";
        ext = "jpg";
      in
      builtins.fetchurl {
        name = "wallpaper-${sha256}.${ext}";
        inherit url sha256;
      };
  };
}
