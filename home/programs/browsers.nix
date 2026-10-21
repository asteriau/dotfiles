{
  programs.firefox.enable = true;

  # flags live in chrome-flags.conf (misc.nix)
  programs.chromium = {
    enable = true;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
    ];
  };
}
