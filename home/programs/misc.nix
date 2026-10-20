{
  # app flag files and the shell's icon
  xdg.dataFile."icons/illogical-impulse.svg".source = ./icons/illogical-impulse.svg;

  xdg.configFile = {
    "chrome-flags.conf".text = ''
      --password-store=gnome-libsecret
      --ozone-platform-hint=wayland
      --gtk-version=4
      --ignore-gpu-blocklist
      --enable-features=TouchpadOverscrollHistoryNavigation
      --enable-wayland-ime
      --disable-features=ExtensionManifestV2Unsupported
    '';
    "code-flags.conf".text = ''
      --ozone-platform-hint=wayland
      --gtk-version=4
      --ignore-gpu-blocklist
      --enable-features=TouchpadOverscrollHistoryNavigation
      --enable-wayland-ime
      --password-store=gnome-libsecret
    '';
    "thorium-flags.conf".text = ''
      --password-store=gnome-libsecret
      # --ozone-platform-hint=wayland
      --gtk-version=4
      --ignore-gpu-blocklist
      --enable-features=TouchpadOverscrollHistoryNavigation
    '';
  };
}
