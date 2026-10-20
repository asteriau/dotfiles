{
  config,
  lib,
  pkgs,
  self,
  quickshell,
  quickshellDeps,
  iiPython,
  ...
}:
let
  inherit (self.packages.${pkgs.stdenv.hostPlatform.system}) microtex;

  # Read by the patched services (see PATCHES.md) and the venv scripts.
  env = {
    MICROTEX_DIR = "${microtex}/opt/MicroTeX";
    ILLOGICAL_IMPULSE_SOUNDS_DIR = "/run/current-system/sw/share/sounds";
    ILLOGICAL_IMPULSE_XKB_RULES = "${pkgs.xkeyboard_config}/share/X11/xkb/rules/base.lst";
    ILLOGICAL_IMPULSE_VIRTUAL_ENV = "${iiPython.fakeVenv}";
  };

  servicePath = lib.concatStringsSep ":" [
    "/run/wrappers/bin"
    (lib.makeBinPath quickshellDeps)
    "/etc/profiles/per-user/${config.home.username}/bin"
    "/run/current-system/sw/bin"
  ];
in
{
  # Also exported to the session so `qs -p settings.qml` from a terminal sees them.
  home.sessionVariables = env;
  # uwsm merges the user manager's environment into the compositor's, which is
  # how Hyprland-bound fallbacks (settings app via Super+I, record.sh, ...) see these.
  systemd.user.sessionVariables = env;

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell (illogical-impulse)";
      PartOf = [
        "tray.target"
        "graphical-session.target"
      ];
      After = "graphical-session.target";
    };
    Service = {
      Environment = lib.mapAttrsToList (k: v: "${k}=${v}") (env // { PATH = servicePath; });
      ExecStart = "${quickshell}/bin/qs -c ii";
      Restart = "on-failure";
      # Apps launched from the shell inherit this unit's cgroup, so the default
      # control-group kill mode would SIGTERM them on restart.
      KillMode = "process";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.targets.tray.Unit.Requires = lib.mkForce [ "graphical-session.target" ];
}
