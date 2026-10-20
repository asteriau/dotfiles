{ pkgs, lib, ... }:
let
  dolphinrc = pkgs.writeText "dolphinrc" (
    lib.generators.toINI { mkSectionName = s: s; } {
      DetailsMode.PreviewSize = 32;
      General = {
        GlobalViewProps = false;
        ShowFullPath = true;
        ShowStatusBar = "FullWidth";
        Version = 202;
      };
      "KFileDialog Settings" = {
        "Places Icons Auto-resize" = false;
        "Places Icons Static Size" = 22;
      };
      MainWindow.MenuBar = "Disabled";
      PreviewSettings.Plugins = "ffmpegthumbnailer,appimagethumbnail,audiothumbnail,avif,blenderthumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,heif,imagethumbnail,jpegthumbnail,jxl,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,mobithumbnail,opendocumentthumbnail,gsthumbnail,rawthumbnail,librsvg,svgthumbnail,ffmpegthumbs,gdk-pixbuf-thumbnailer,gsf-office";
    }
  );
in
{
  home.packages = with pkgs.kdePackages; [
    dolphin
    systemsettings # upstream illogical-impulse-kde; settingsApp fallback in variables.lua
  ];

  home.activation.dolphinSeed = lib.hm.dag.entryAfter [ "writeBoundary" "linkGeneration" ] ''
    [ -e "$HOME/.config/dolphinrc" ] || run install -Dm644 ${dolphinrc} "$HOME/.config/dolphinrc"
  '';
}
