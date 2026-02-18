{
  programs.wezterm = {
    enable = true;

    extraConfig = ''
      local wezterm = require "wezterm"

      return {
        check_for_updates = false,

        font = wezterm.font("JetBrains Mono Nerd Font"),
        font_size = 14,

        default_cursor_style = "SteadyBar",

        enable_scroll_bar = true,
        hide_tab_bar_if_only_one_tab = true,
        scrollback_lines = 10000,

        window_background_opacity = 1.0,

        colors = {
          foreground = "#E8E3E3",
          background = "#151515",

          cursor_bg = "#E8E3E3",
          cursor_fg = "#151515",
          cursor_border = "#E8E3E3",

          selection_fg = "#8DA3B9",
          selection_bg = "#151515",

          ansi = {
            "#151515", -- black
            "#B66467", -- red
            "#8C977D", -- green
            "#D9BC8C", -- yellow
            "#8DA3B9", -- blue
            "#A988B0", -- magenta
            "#8AA6A2", -- cyan
            "#E8E3E3", -- white
          },

          brights = {
            "#424242", -- bright black
            "#B66467", -- bright red
            "#8C977D", -- bright green
            "#D9BC8C", -- bright yellow
            "#8DA3B9", -- bright blue
            "#A988B0", -- bright magenta
            "#8AA6A2", -- bright cyan
            "#E8E3E3", -- bright white
          },
        },
      }
    '';
  };
}
