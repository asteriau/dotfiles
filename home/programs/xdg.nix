{ config, ... }:
let
  browser = [ "zen.desktop" ];
in
{
  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/xhtml+xml" = browser;
        "text/html" = browser;
        "x-scheme-handler/about" = browser;
        "x-scheme-handler/http" = browser;
        "x-scheme-handler/https" = browser;
        "x-scheme-handler/unknown" = browser;

        "inode/directory" = [ "org.kde.dolphin.desktop" ];
        "text/plain" = [ "code.desktop" ];

        "video/avi" = [ "mpv.desktop" ];
        "video/mp4" = [ "mpv.desktop" ];
        "video/x-matroska" = [ "mpv.desktop" ];
      };
    };

    userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
      extraConfig.SCREENSHOTS = "${config.xdg.userDirs.pictures}/Screenshots";
    };
  };
}
