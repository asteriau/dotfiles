{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting

      # terminal colours written by the shell's applycolor.sh
      if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
          cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
      end

      alias clear "printf '\033[2J\033[3J\033[1;1H'"
      alias celar "printf '\033[2J\033[3J\033[1;1H'"
      alias claer "printf '\033[2J\033[3J\033[1;1H'"
      alias q 'qs -c ii'
      if test "$TERM" != "linux"
          alias ls 'eza --icons=auto'
      end
    '';
  };
}
