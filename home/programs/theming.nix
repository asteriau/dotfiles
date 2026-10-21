{
  pkgs,
  lib,
  self,
  ...
}:
let
  ii = self.packages.${pkgs.stdenv.hostPlatform.system};
  toINI = lib.generators.toINI { mkSectionName = s: s; };

  kdeglobals = pkgs.writeText "kdeglobals" (toINI (import ./kdeglobals.nix));
  darklyrc = pkgs.writeText "darklyrc" (toINI {
    Style.WidgetDrawShadow = false;
  });
  dconfSeed = pkgs.writeText "ii-dconf" ''
    [org/gnome/desktop/interface]
    color-scheme='prefer-dark'
    gtk-theme='adw-gtk3-dark'
    font-name='Google Sans Flex Medium 11 @opsz=11,wght=500'
  '';
in
{
  # QT_PLUGIN_PATH / QML2_IMPORT_PATH to the per-user profile, so kcmshell6
  # finds the bluedevil/plasma-nm KCMs and Qt apps find the Darkly style.
  # QT_QPA_PLATFORMTHEME=kde is set by the upstream Hyprland env.lua.
  qt = {
    enable = true;
    platformTheme.name = "kde";
  };

  home.packages = with pkgs; [
    adw-gtk3
    darkly
    kdePackages.breeze # Breeze Qt style + cursors
    kdePackages.breeze-icons
    ii.breeze-plus
    ii.bibata-hyprcursor
    bibata-cursors
  ];

  xdg.configFile = {
    "Kvantum/kvantum.kvconfig".text = toINI { General.theme = "MaterialAdw"; };
    # theme assets; MaterialAdw is seeded below because kde-material-you-colors regenerates it
    "Kvantum/Colloid".source = ./Kvantum/Colloid;

    "kde-material-you-colors/config.conf".text = toINI {
      CUSTOM = {
        monitor = 0;
        file = "~/.local/state/quickshell/user/generated/wallpaper/path.txt";
        custom_colors_list = "#ED8796 #A6DA95 #EED49F #8AADF4 #F5BDE6 #8BD5CA #f5a97f";
        ncolor = 0;
        iconslight = "breeze-plus";
        iconsdark = "breeze-plus-dark";
        pywal = "False";
        scheme_variant = 5;
        chroma_multiplier = 1;
        tone_multiplier = 1;
      };
    };
  };

  # Written at runtime by kwriteconfig6 / kde-material-you-colors, so seeded
  # writable once instead of linked. Mirrors the installer's one-time setup.
  home.activation.illogicalImpulseTheming =
    lib.hm.dag.entryAfter [ "writeBoundary" "linkGeneration" ]
      ''
        [ -e "$HOME/.config/kdeglobals" ] || run install -Dm644 ${kdeglobals} "$HOME/.config/kdeglobals"
        [ -e "$HOME/.config/darklyrc" ] || run install -Dm644 ${darklyrc} "$HOME/.config/darklyrc"
        if [ ! -e "$HOME/.config/Kvantum/MaterialAdw" ]; then
          run mkdir -p "$HOME/.config/Kvantum"
          run cp -r ${./Kvantum/MaterialAdw} "$HOME/.config/Kvantum/MaterialAdw"
          run chmod -R u+w "$HOME/.config/Kvantum/MaterialAdw"
        fi
        run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Darkly || true
        # switchwall.sh flips color-scheme and gtk-theme at runtime, so they are seeded, not enforced
        if [ ! -e "$HOME/.local/state/quickshell/.dconf-seeded" ]; then
          if [ -n "''${DBUS_SESSION_BUS_ADDRESS:-}" ]; then
            run ${pkgs.dconf}/bin/dconf load / < ${dconfSeed}
          else
            run ${pkgs.dbus}/bin/dbus-run-session -- ${pkgs.dconf}/bin/dconf load / < ${dconfSeed}
          fi
          run mkdir -p "$HOME/.local/state/quickshell"
          run touch "$HOME/.local/state/quickshell/.dconf-seeded"
        fi
      '';
}
