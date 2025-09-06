{
  config,
  lib,
  ...
}:
let
  cfg = config.cosmic;
in
{
  imports = [ ./wayland-common.nix ];

  options = {
    cosmic = {
      enable = lib.mkEnableOption "cosmic";
    };
  };

  config = lib.mkIf cfg.enable {
    wayland-common.enable = true;
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;
  };
}
