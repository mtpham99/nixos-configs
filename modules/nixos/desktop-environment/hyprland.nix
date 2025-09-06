{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.hyprland;
in
{
  imports = [ ./wayland-common.nix ];

  options = {
    hyprland = {
      enable = lib.mkEnableOption "hyprland";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };

    wayland-common.enable = true;
    programs.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;

      withUWSM = true;
    };
  };
}
