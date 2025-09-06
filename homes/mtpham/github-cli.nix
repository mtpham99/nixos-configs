{
  config,
  lib,
  ...
}:
let
  cfg = config.github-cli;
in
{
  options = {
    github-cli = {
      enable = lib.mkEnableOption "github-cli";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;

      userName = "Matthew T. Pham";
      userEmail = "pham.matthew+git@protonmail.com";

      signing = {
        signByDefault = true;
        key = "7E217574BF8B385B";
        format = "openpgp";
      };

      extraConfig.init.defaultBranch = "main";
    };

    programs.gh = {
      enable = true;

      settings = {
        editor = "";
        git_protocol = "ssh";
        prompt = "enable";
      };
    };

    programs.ssh.matchBlocks."github.com".extraOptions = {
      User = "git";
      IdentityFile = "${config.home.homeDirectory}/.ssh/mtpham_grunfeld";
    };
  };
}
