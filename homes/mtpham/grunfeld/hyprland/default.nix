{
  config,
  lib,
  ...
}:
let
  cfg = config.desktop-environment.hyprland;
in
{
  imports = [
    ./hyprland.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./hyprpaper.nix

    ./dunst.nix
    ./walker.nix
  ];

  options = {
    desktop-environment.hyprland = {
      enable = lib.mkEnableOption "hyprland";
    };
  };

  config = lib.mkIf cfg.enable {
    services.hyprpolkitagent.enable = true;
    hyprland.enable = true;
    hyprlock.enable = true;
    hyprpaper.enable = true;
    hypridle.enable = true;

    services.copyq.enable = true;
    dunst.enable = true;
    walker.enable = true;
  };
}
