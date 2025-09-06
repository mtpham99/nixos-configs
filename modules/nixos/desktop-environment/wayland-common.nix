{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.wayland-common;
in
{
  options = {
    wayland-common = {
      enable = lib.mkEnableOption "wayland-common";
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland";
      };

      systemPackages = [
        pkgs.wlr-randr
        pkgs.wayland-utils
      ];
    };
  };
}
