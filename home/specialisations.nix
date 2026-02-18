{
  theme = {
    wallpaper =
      let
        url = "https://github.com/asteriau/dotfiles/blob/main/assets/wallpapers/sea.jpg?raw=true";
        sha256 = "bf428ae45074a16f6388d43021d1ade20d2052e570704410105971c14980e3f1";
        ext = "jpg";
      in
      builtins.fetchurl {
        name = "wallpaper-${sha256}.${ext}";
        inherit url sha256;
      };
  };
}
