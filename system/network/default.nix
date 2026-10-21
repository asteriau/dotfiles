{ pkgs, ... }:
{
  imports = [
    ./avahi.nix
    ./mullvad.nix
    ./tailscale.nix
  ];

  networking = {
    nameservers = [ "9.9.9.9#dns.quad9.net" ];

    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
    };
  };

  services = {
    openssh = {
      enable = true;
      settings.UseDns = true;
    };

    resolved.enable = true;
  };

  systemd.services.NetworkManager-wait-online.serviceConfig.ExecStart = [
    ""
    "${pkgs.networkmanager}/bin/nm-online -q"
  ];
}
