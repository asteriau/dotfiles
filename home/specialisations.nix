{
  theme = {
    wallpaper =
      let
        url = "https://github.com/asteriau/dotfiles/blob/main/assets/wallpapers/cat.png?raw=true";
        sha256 = "c1989f287d8a63f05a644cebd24e3f58db736a623704ee1d61915befe85a4f13";
        ext = "cat";
      in
      builtins.fetchurl {
        name = "wallpaper-${sha256}.${ext}";
        inherit url sha256;
      };
  };
}
