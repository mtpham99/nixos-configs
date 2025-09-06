{
  config,
  lib,
  ...
}:
let
  cfg = config.desktop-environment;
in
{
  imports = [
    ./cosmic.nix
    ./hyprland.nix
  ];

  options = {
    desktop-environment = {
      enable = lib.mkEnableOption "enable a desktop environment";

      desktop = lib.mkOption {
        type = lib.types.enum [
          "cosmic"
          "hyprland"
        ];
        description = "desktop environment to use";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    cosmic.enable = cfg.desktop == "cosmic";
    hyprland.enable = cfg.desktop == "hyprland";
  };
}
