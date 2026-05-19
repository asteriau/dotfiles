--------------------------
---- ENVIRONMENT VARS ----
--------------------------
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("HYPRCURSOR_THEME", cursorName)
hl.env("HYPRCURSOR_SIZE", cursorSize)
-- See https://github.com/hyprwm/contrib/issues/142
hl.env("GRIMBLAST_NO_CURSOR", "0")

-------------------
---- MONITORS -----
-------------------
hl.monitor({ output = "DP-1", mode = "1920x1080@165", position = "0x0", scale = 1 })

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
  hl.exec_cmd("hyprctl setcursor " .. cursorName .. " " .. cursorSize)
end)

--------------------------
---- GENERAL SETTINGS ----
--------------------------
hl.config({
  general = {
    gaps_in = gaps_in,
    gaps_out = gaps_out,
    border_size = border_size,
    col = {
      active_border = border_active_color,
      inactive_border = border_inactive_color,
    },
    allow_tearing = false,
    resize_on_border = true,
  },

  group = {
    groupbar = {
      font_size = 10,
      gradients = false,
      text_color = group_text_color,
    },
    col = {
      border_active = group_border_active_color,
      border_inactive = group_border_inactive_color,
    },
  },

  input = {
    kb_layout = "ro",
    follow_mouse = 1,
    accel_profile = "flat",
    tablet = {
      output = "current",
    },
  },

  dwindle = {
    preserve_split = true,
  },

  misc = {
    force_default_wallpaper = 0,
    background_color = background_color,
    animate_mouse_windowdragging = false,
    vrr = 1,
  },

  render = {
    direct_scanout = false, -- this breaks nvidia stuff
  },

  xwayland = {
    force_zero_scaling = true,
  },
})

-----------------------
----- PERMISSIONS -----
-----------------------
hl.permission({ binary = portal_hyprland, type = "screencopy", mode = "allow" })
hl.permission({ binary = grim_bin, type = "screencopy", mode = "allow" })
hl.permission({ binary = wl_screenrec_bin, type = "screencopy", mode = "allow" })
