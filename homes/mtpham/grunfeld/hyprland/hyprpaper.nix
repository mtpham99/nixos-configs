{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.hyprpaper;
  wallpapers = inputs.assets + "/wallpapers";
in
{
  options = {
    hyprpaper = {
      enable = lib.mkEnableOption "hyprpaper";
    };
  };

  config = lib.mkIf cfg.enable {
    services.hyprpaper = {
      enable = true;

      settings = {
        ipc = "on";
        splash = false;
        preload = [ (wallpapers + "/black_1920x1080.png") ];
        wallpaper = [ (wallpapers + "/black_1920x1080.png") ];
      };
    };
  };
}
