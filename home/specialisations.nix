{
  theme = {
    wallpaper =
      let
        url = "https://github.com/asteriau/dotfiles/blob/main/assets/wallpapers/furina.jpeg?raw=true";
        sha256 = "d3a09f48f86a8de83654ad7828514133600f837e5522aa5545946fe8c73ebe23";
        ext = "jpeg";
      in
      builtins.fetchurl {
        name = "wallpaper-${sha256}.${ext}";
        inherit url sha256;
      };
  };
}
