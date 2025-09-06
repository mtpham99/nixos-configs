{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.gnupg;
in
{
  options = {
    gnupg = {
      enable = lib.mkEnableOption "gnupg";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-curses;
    };
  };
}
