{
  config,
  profile,
  ...
}:
{
  home.file.".config/quickshell".source =
    config.lib.file.mkOutOfStoreSymlink "${profile.flakePath}/home/services/quickshell";
}
