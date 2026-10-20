{
  pkgs,
  lib,
  self,
  ...
}:
let
  ii = self.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = with pkgs; [
    adw-gtk3
    darkly
    kdePackages.breeze-icons
    ii.breeze-plus
    ii.bibata-hyprcursor
    bibata-cursors
  ];

  xdg.configFile = {
    "Kvantum".source = ./Kvantum;
    "kde-material-you-colors/config.conf".source = ./kde-material-you-colors.conf;
    "fontconfig/fonts.conf".source = ./fonts.conf;
  };

  # kwriteconfig6 and kde-material-you-colors write these, so they are seeded
  # once instead of linked. Mirrors the installer's one-time setup calls.
  home.activation.illogicalImpulseTheming = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    for f in kdeglobals darklyrc; do
      [ -e "$HOME/.config/$f" ] || run install -Dm644 "${./seed}/$f" "$HOME/.config/$f"
    done
    run ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme prefer-dark || true
    run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle Darkly || true
  '';
}
