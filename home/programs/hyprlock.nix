{ lib, pkgs, ... }:
let
  # upstream hyprlock/status.sh
  status = pkgs.writeShellScript "hyprlock-status" ''
    enable_battery=false
    battery_charging=false
    for battery in /sys/class/power_supply/*BAT*; do
      if [[ -f "$battery/uevent" ]]; then
        enable_battery=true
        if [[ $(cat /sys/class/power_supply/*/status | head -1) == "Charging" ]]; then
          battery_charging=true
        fi
        break
      fi
    done
    if [[ $enable_battery == true ]]; then
      [[ $battery_charging == true ]] && echo -n "(+) "
      echo -n "$(cat /sys/class/power_supply/*/capacity | head -1)"%
      [[ $battery_charging == false ]] && echo -n " remaining"
    fi
    echo ""
  '';

  # upstream hyprlock/check-capslock.sh
  checkCapslock = pkgs.writeShellScript "hyprlock-check-capslock" ''
    caps=$(${pkgs.hyprland}/bin/hyprctl devices | grep -B 6 "main: yes" | grep "capsLock" | head -1 | awk '{print $2}')
    if [ "$caps" = "yes" ]; then echo "Caps Lock active"; else echo ""; fi
  '';

  # matugen rewrites this file; these are upstream's shipped defaults
  colorsConf = pkgs.writeText "hyprlock-colors.conf" ''
    $text_color = rgba(d9e2ffFF)
    $entry_background_color = rgba(00194411)
    $entry_border_color = rgba(8f909955)
    $entry_color = rgba(d9e2ffFF)
    $font_family = Google Sans Flex Medium
    $font_family_clock = Google Sans Flex Medium
    $font_material_symbols = Material Symbols Rounded
  '';

  label =
    extra:
    {
      monitor = "";
      color = "$text_color";
      font_family = "$font_family";
    }
    // extra;

  hyprlockConf = pkgs.writeText "hyprlock.conf" (
    lib.hm.generators.toHyprconf {
      importantPrefixes = [ "source" ];
      attrs = {
        source = "~/.config/hypr/hyprlock/colors.conf";

        background.color = "rgba(181818FF)";

        input-field = {
          monitor = "";
          size = "250, 50";
          outline_thickness = 2;
          dots_size = 0.1;
          dots_spacing = 0.3;
          outer_color = "$entry_border_color";
          inner_color = "$entry_background_color";
          font_color = "$entry_color";
          fade_on_empty = true;
          position = "0, 20";
          halign = "center";
          valign = "center";
        };

        label = [
          # keyboard layout
          (label {
            text = "$LAYOUT";
            font_size = 14;
            position = "-30, 30";
            halign = "right";
            valign = "bottom";
          })
          # caps lock warning
          (label {
            text = "cmd[update:250] ${checkCapslock}";
            font_size = 13;
            position = "0, -25";
            halign = "center";
            valign = "center";
          })
          # clock; the settings app toggles $TIME/$TIME12 with sed, hence the seeded copy
          (label {
            text = "$TIME";
            font_size = 65;
            font_family = "$font_family_clock";
            position = "0, 300";
            halign = "center";
            valign = "center";
          })
          # date
          (label {
            text = "cmd[update:5000] date +\"%A, %B %d\"";
            font_size = 17;
            font_family = "$font_family_clock";
            position = "0, 240";
            halign = "center";
            valign = "center";
          })
          # user
          (label {
            text = "    $USER";
            outline_thickness = 2;
            dots_size = 0.2;
            dots_spacing = 0.2;
            dots_center = true;
            font_size = 20;
            position = "0, 50";
            halign = "center";
            valign = "bottom";
          })
          # status (battery)
          (label {
            text = "cmd[update:5000] ${status}";
            font_size = 14;
            position = "30, -30";
            halign = "left";
            valign = "top";
          })
        ];
      };
    }
  );
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "hyprctl dispatch 'hl.dsp.global(\"quickshell:lock\")' & pidof qs quickshell hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch 'hl.dsp.global(\"quickshell:lockFocus\")'";
        inhibit_sleep = 3;
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"disable\" })'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
        }
        {
          timeout = 900;
          on-timeout = "systemctl suspend || loginctl suspend";
        }
      ];
    };
  };

  # hyprlock.conf is edited in place by the settings app and colors.conf by
  # matugen, so both are seeded writable instead of linked.
  home.activation.hyprlockSeed = lib.hm.dag.entryAfter [ "writeBoundary" "linkGeneration" ] ''
    [ -e "$HOME/.config/hypr/hyprlock.conf" ] || run install -Dm644 ${hyprlockConf} "$HOME/.config/hypr/hyprlock.conf"
    [ -e "$HOME/.config/hypr/hyprlock/colors.conf" ] || run install -Dm644 ${colorsConf} "$HOME/.config/hypr/hyprlock/colors.conf"
  '';
}
