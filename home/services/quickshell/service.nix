{
  lib,
  config,
  quickshell,
  quickshellDeps,
  QML2_IMPORT_PATH,
  ...
}:
{
  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell";
      PartOf = [
        "tray.target"
        "graphical-session.target"
      ];
      After = "graphical-session.target";
    };
    Service = {
      Environment = "PATH=/run/wrappers/bin:${lib.makeBinPath quickshellDeps}:${config.home.homeDirectory}/.nix-profile/bin:/etc/profiles/per-user/${config.home.username}/bin:/run/current-system/sw/bin QML2_IMPORT_PATH=${QML2_IMPORT_PATH}";
      ExecStart = lib.getExe quickshell;
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
