{
  programs.hyprland.settings.decoration = {
    rounding = 10;
    rounding_power = 2.5;
    blur = {
      enabled = true;
      brightness = 1.0;
      contrast = 1.0;
      noise = 0.01;

      vibrancy = 0.2;
      vibrancy_darkness = 0.5;

      passes = 4;
      size = 7;

      popups = true;
      popups_ignorealpha = 0.2;
    };

    shadow = {
      enabled = true;
      color = "rgba(00000055)";
      ignore_window = true;
      offset = "0 15";
      range = 100;
      render_power = 2;
      scale = 0.97;
    };
  };
}
