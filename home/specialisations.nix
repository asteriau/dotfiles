{
  theme = {
    wallpaper =
      let
        url = "https://github.com/asteriau/dotfiles/blob/main/home/wallpapers/pink.jpg?raw=true";
        sha256 = "243e1c1e92894bc80879ef803dc169e78fa8e887703d95ce53a4474dfd61918f";
        ext = "jpg";
      in
      builtins.fetchurl {
        name = "wallpaper-${sha256}.${ext}";
        inherit url sha256;
      };
  };
}
