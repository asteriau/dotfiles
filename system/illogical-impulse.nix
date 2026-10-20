{ pkgs, profile, ... }:
{
  # virtual keyboard / input injection used by the on-screen keyboard
  programs.ydotool.enable = true;

  # ddcutil external-monitor brightness (i2c-dev module is loaded by the host)
  hardware.i2c.enable = true;

  # QtPositioning location for the weather widget; the demo agent is a user service
  services.geoclue2 = {
    enable = true;
    enableDemoAgent = true;
  };

  # hyprlock is the fallback locker when the shell's own lock screen is unavailable
  security.pam.services.hyprlock = { };

  environment.systemPackages = with pkgs; [
    sound-theme-freedesktop # Audio.qml system sounds
    xkeyboard_config # also referenced directly by ILLOGICAL_IMPULSE_XKB_RULES
  ];

  users.users.${profile.user}.extraGroups = [
    "i2c"
    "input"
    "video"
    "ydotool"
  ];
}
