{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.ghostty;
in
{
  options = {
    ghostty = {
      enable = lib.mkEnableOption "ghostty";
      defaultTerminal = lib.mkEnableOption "ghostty as default terminal";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.terminal-exec = {
      settings = {
        default = lib.optionals cfg.defaultTerminal [ "ghostty.desktop" ];
      };
    };

    programs.ghostty = {
      enable = true;
    };
  };
}
