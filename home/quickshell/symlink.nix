{ config, profile, ... }:
{
  # Out-of-store so QML edits hot-reload; qs -c ii resolves ~/.config/quickshell/ii/shell.qml
  home.file.".config/quickshell".source =
    config.lib.file.mkOutOfStoreSymlink "${profile.flakePath}/home/quickshell";
}
