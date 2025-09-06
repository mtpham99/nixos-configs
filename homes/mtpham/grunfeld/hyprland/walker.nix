{
  inputs,
  config,
  lib,
  ...
}:
let
  cfg = config.walker;
in
{
  imports = [ inputs.walker.homeManagerModules.walker ];

  options = {
    walker = {
      enable = lib.mkEnableOption "walker";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      substituters = [
        "https://walker.cachix.org"
        "https://walker-git.cachix.org"
      ];
      trusted-public-keys = [
        "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
        "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
      ];
    };

    programs.walker = {
      enable = true;
      runAsService = true;
    };
  };
}
