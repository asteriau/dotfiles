{ inputs, pkgs, ... }:
{
  home.packages = [ inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default ];

  # flags live in chrome-flags.conf (misc.nix)
  programs.chromium = {
    enable = true;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
      { id = "bkkmolkhemgaeaeggcmfbghljjjoofoh"; } # Catppuccin Mocha theme
    ];
  };
}
