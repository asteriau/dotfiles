{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting

      function starship_transient_prompt_func
          starship module character
      end
      if test "$TERM" != "linux"
          starship init fish | source
          enable_transience
      end

      # terminal colours written by the shell's applycolor.sh
      if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
          cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
      end

      alias clear "printf '\033[2J\033[3J\033[1;1H'"
      alias celar "printf '\033[2J\033[3J\033[1;1H'"
      alias claer "printf '\033[2J\033[3J\033[1;1H'"
      alias q 'qs -c tachyon'
      if test "$TERM" != "linux"
          alias ls 'eza --icons=auto'
      end
    '';
  };
}
