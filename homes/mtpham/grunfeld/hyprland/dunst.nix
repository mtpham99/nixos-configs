{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.dunst;
in
{
  options = {
    dunst = {
      enable = lib.mkEnableOption "dunst";
    };
  };

  config = lib.mkIf cfg.enable {
    services.dunst = {
      enable = true;

      iconTheme = {
        name = "papirus";
        package = pkgs.papirus-icon-theme;
      };

      settings = {
        global = {
          width = 480;
          height = 240;
          origin = "top-right";
          padding = 3;
          horizontal_padding = 3;

          notification_limit = 0;
          gap_size = 3;

          frame_width = 3;
          frame_color = "#a8a8a8";

          markup = "full";
        };

        urgency_low = {
          timeout = 10;
          default_icon = "dialog-information";
          background = "#000000";
          foreground = "#777777";
        };

        urgency_normal = {
          timeout = 10;
          override_pause_level = 30;
          default_icon = "dialog-information";
          background = "#000000";
          foreground = "#777777";
        };

        urgency_critical = {
          timeout = 0;
          override_pause_level = 60;
          default_icon = "dialog-warning";
          background = "#d64e4e";
          foreground = "#777777";
        };
      };
    };
  };
}
