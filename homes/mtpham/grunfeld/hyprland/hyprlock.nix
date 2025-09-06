{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.hyprlock;
  wallpapers = inputs.assets + "/wallpapers";
in
{
  options = {
    hyprlock = {
      enable = lib.mkEnableOption "hyprlock";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.hyprlock = {
      enable = true;

      settings = {
        general.ignore_empty_input = true;
        auth.fingerprint.enabled = true;

        input-field = [
          {
            position = "0, 0";
            halign = "center";
            valign = "center";
            size = "500, 50";
          }
        ];

        background = [ { path = wallpapers + "/black_1920x1080.png"; } ];

        label = [
          # clock
          {
            position = "0, -100";
            halign = "center";
            valign = "top";

            text = "cmd[update:1000] echo $(date '+%H:%M:%S %Z')";
            # font_family = "";
            font_size = 64;
            font_color = "rgba(128, 128, 128, 0.5)";
          }

          # date
          {
            position = "0, 100";
            halign = "center";
            valign = "bottom";

            text = "cmd[update:1000] echo $(date '+%A, %d %B %Y')";
            # font_family = "";
            font_size = 48;
            font_color = "rgba(128, 128, 128, 0.5)";
          }
        ];
      };
    };
  };
}
