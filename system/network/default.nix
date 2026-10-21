{ pkgs, ... }:
{
  networking = {
    nameservers = [ "9.9.9.9#dns.quad9.net" ];

    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };
  };

  services.resolved.enable = true;

  systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart = [
    ""
    "${pkgs.networkmanager}/bin/nm-online -q"
  ];
}
