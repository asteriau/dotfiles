{
  config,
  pkgs,
  lib,
  ...
}:
{
  # yazi runs exiftool for file info
  home.packages = [ pkgs.exiftool ];

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    shellWrapperName = "y";

    settings = {
      mgr = {
        layout = [
          1
          4
          3
        ];
        sort_by = "alphabetical";
        sort_sensitive = true;
        sort_reverse = false;
        sort_dir_first = true;
        linemode = "none";
        show_hidden = false;
        show_symlink = true;
      };

      preview = {
        tab_size = 2;
        max_width = 600;
        max_height = 900;
        cache_dir = config.xdg.cacheHome;
      };
    };

    # C-n drags the selection out with ripdrag
    keymap.mgr.prepend_keymap = [
      {
        on = [ "<C-n>" ];
        run = ''shell '${lib.getExe pkgs.ripdrag} "$@" -x 2>/dev/null &' --confirm'';
      }
    ];
  };
}
