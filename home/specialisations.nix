{
  theme = {
    wallpaper =
      let
        url = "https://github.com/asteriau/dotfiles/blob/main/assets/wallpapers/angel.jpg?raw=true";
        sha256 = "a9be082f89c3039a4c99d7470658d600b1f02d640d5ba7725532ddb68368065c";
        ext = "jpg";
      in
      builtins.fetchurl {
        name = "wallpaper-${sha256}.${ext}";
        inherit url sha256;
      };
  };
}
