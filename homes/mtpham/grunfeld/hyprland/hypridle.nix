{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.hypridle;
in
{
  imports = [ ./hyprlock.nix ];

  options = {
    hypridle = {
      enable = lib.mkEnableOption "hypridle";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.brightnessctl ];

    hyprlock.enable = true;

    services.hypridle = {
      enable = true;

      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock -q";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            # dim screen
            timeout = 300;
            on-timeout = "brightnessctl -s set 10%";
            on-resume = "brightnessctl -r";
          }
          {
            # dim keyboard
            timeout = 300;
            on-timeout = "brightnessctl -sd tpacpi::kbd_backlight set 0";
            on-resume = "brightnessctl -rd tpacpi::kbd_backlight";
          }
          {
            # lock screen
            timeout = 600;
            on-timeout = "loginctl lock-session";
          }
          {
            # turn off display
            timeout = 900;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on && brightnessctl -r";
          }
          {
            # suspend
            timeout = 1800;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
