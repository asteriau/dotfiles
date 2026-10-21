{ pkgs, ... }:
{
  home.packages = with pkgs; [
    chafa
    duf
    dust
    fd
    jaq
    nitch
    ripdrag
    sshfs
    unrar
    unzip
    zip
  ];

  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
    MANROFFOPT = "-c";
  };

  programs = {
    bat = {
      enable = true;
      config.pager = "less -FR";
    };

    btop.enable = true;

    skim = {
      enable = true;
      enableFishIntegration = true;
      defaultCommand = "rg --files --hidden";
      changeDirWidgetOptions = [
        "--preview 'eza --icons --git --color always -T -L 3 {} | head -200'"
        "--exact"
      ];
    };

    zoxide.enable = true;
  };
}
