---------------------
---- KEYBINDINGS ----
---------------------

local function toggle(program)
  local prog = program:sub(1, 14)
  return "pkill " .. prog .. " || uwsm app -- " .. program
end

local function runOnce(program)
  return "pgrep " .. program .. " || uwsm app -- " .. program
end

-- mouse movements
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true, description = "Window: Move window" })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true, description = "Window: Resize floating window" })
hl.bind(mod .. " + ALT + mouse:272", hl.dsp.window.resize(), { mouse = true, description = "Window: Resize tiled window" })

-- compositor commands
hl.bind(mod .. " + Q", hl.dsp.window.close(), { description = "Window: Close active" })
hl.bind(mod .. " + F", hl.dsp.window.fullscreen(), { description = "Window: Fullscreen" })
hl.bind(mod .. " + G", hl.dsp.group.toggle(), { description = "Window: Toggle group" })
hl.bind(mod .. " + SHIFT + N", hl.dsp.group.next(), { description = "Window: Next in group" })
hl.bind(mod .. " + SHIFT + P", hl.dsp.group.prev(), { description = "Window: Previous in group" })
hl.bind(mod .. " + R", hl.dsp.layout("togglesplit"), { description = "Window: Toggle split" })
hl.bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }), { description = "Window: Toggle floating" })
hl.bind(mod .. " + P", hl.dsp.window.pseudo(), { description = "Window: Toggle pseudo" })

-- utility
hl.bind(mod .. " + Return", hl.dsp.exec_cmd("uwsm app -- foot"), { description = "App: Terminal" })
hl.bind(mod .. " + Escape", hl.dsp.exec_cmd(toggle("wlogout") .. " -p layer-shell"), { description = "App: Logout menu" })
hl.bind(mod .. " + O", hl.dsp.exec_cmd(runOnce("wl-ocr")), { description = "Utilities: OCR selection" })
hl.bind("XF86Favorites", hl.dsp.exec_cmd(runOnce("wl-ocr")), { description = "Utilities: OCR selection" })
hl.bind(mod .. " + Slash", hl.dsp.exec_cmd("qs ipc call cheatsheet toggle"), { description = "Shell: Toggle cheatsheet" })

-- move focus
hl.bind(mod .. " + left", hl.dsp.focus({ direction = "l" }), { description = "Window: Focus left" })
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "r" }), { description = "Window: Focus right" })
hl.bind(mod .. " + up", hl.dsp.focus({ direction = "u" }), { description = "Window: Focus up" })
hl.bind(mod .. " + down", hl.dsp.focus({ direction = "d" }), { description = "Window: Focus down" })

-- screenshot / recording
hl.bind("Print", hl.dsp.exec_cmd("grim - | wl-copy"), { description = "Screenshot: Fullscreen to clipboard" })
hl.bind(mod .. " + SHIFT + S", hl.dsp.global("quickshell:regionScreenshot"), { description = "Screenshot: Region screenshot" })
hl.bind(mod .. " + SHIFT + R", hl.dsp.global("quickshell:regionRecord"), { description = "Screenshot: Region recording" })
hl.bind(mod .. " + SHIFT + ALT + R", hl.dsp.exec_cmd("bash $HOME/.config/quickshell/scripts/record.sh --fullscreen --sound"), { description = "Screenshot: Fullscreen recording" })

-- cycle workspaces
hl.bind(mod .. " + bracketleft", hl.dsp.focus({ workspace = "m-1" }), { description = "Workspace: Previous active" })
hl.bind(mod .. " + bracketright", hl.dsp.focus({ workspace = "m+1" }), { description = "Workspace: Next active" })

-- cycle monitors
hl.bind(mod .. " + SHIFT + bracketleft", hl.dsp.focus({ monitor = "l" }), { description = "Monitor: Focus left" })
hl.bind(mod .. " + SHIFT + bracketright", hl.dsp.focus({ monitor = "r" }), { description = "Monitor: Focus right" })

-- send focused workspace to left/right monitors
hl.bind(mod .. " + SHIFT + ALT + bracketleft", hl.dsp.workspace.move({ monitor = "l" }), { description = "Monitor: Send workspace left" })
hl.bind(mod .. " + SHIFT + ALT + bracketright", hl.dsp.workspace.move({ monitor = "r" }), { description = "Monitor: Send workspace right" })

-- workspaces
for i = 1, 10 do
  local key = i % 10
  if i == 1 then
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }), { description = "Workspace: Switch to workspace [1-10]" })
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), { description = "Workspace: Move window to workspace [1-10]" })
  else
    hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
  end
end

-- launcher (release bind)
hl.bind(mod .. " + SUPER_L", hl.dsp.exec_cmd("qs ipc call launcher toggle"), { release = true, description = "Shell: Toggle launcher" })

-- media controls (locked)
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, description = "Media: Play/Pause" })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true, description = "Media: Previous" })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true, description = "Media: Next" })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, description = "Volume: Mute output" })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, description = "Volume: Mute microphone" })

-- volume (locked + repeating)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 6%+"), { locked = true, repeating = true, description = "Volume: Raise" })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume -l '1.0' @DEFAULT_AUDIO_SINK@ 6%-"), { locked = true, repeating = true, description = "Volume: Lower" })

-- backlight (locked + repeating)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brillo -q -u 300000 -A 5"), { locked = true, repeating = true, description = "Backlight: Increase" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brillo -q -u 300000 -U 5"), { locked = true, repeating = true, description = "Backlight: Decrease" })
