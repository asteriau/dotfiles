{ pkgs, ... }:
{
  systemd.user.services.cliphist = {
    Unit = {
      Description = "Clipboard history watcher";
      PartOf = [ "graphical-session.target" ];
      After = "graphical-session.target";
    };
    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
