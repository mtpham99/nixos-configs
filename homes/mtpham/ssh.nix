{
  config,
  lib,
  ...
}:
let
  cfg = config.ssh;
in
{
  options = {
    ssh = {
      enable = lib.mkEnableOption "ssh";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      matchBlocks."*".extraOptions = {
        ControlPath = "${config.home.homeDirectory}/.ssh/%r@%h:%p.sock";
        ControlMaster = "auto";
        ControlPersist = "1h";
      };
    };
  };
}
