{
  inputs,
  config,
  pkgs,
  lib,
  hostConfig ? null,
  ...
}:

{
  imports = [
    ./sops.nix

    ./gnupg.nix
    ./ssh.nix
    ./github-cli.nix

    ./firefox.nix

    # TODO: reorganize host specific and nix independent configs into external repos
    ./grunfeld/hyprland
    { desktop-environment.hyprland.enable = true; }
  ];

  config = {
    home = {
      username = "mtpham";
      homeDirectory = "/home/mtpham";

      # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "25.05";
    };

    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;

        desktop = config.home.homeDirectory + "/desktop";
        documents = config.home.homeDirectory + "/documents";
        download = config.home.homeDirectory + "/downloads";
        music = config.home.homeDirectory + "/music";
        pictures = config.home.homeDirectory + "/pictures";
        publicShare = config.home.homeDirectory + "/public";
        templates = config.home.homeDirectory + "/templates";
        videos = config.home.homeDirectory + "/videos";
      };
    };

    gnupg.enable = true;
    ssh.enable = true;
    github-cli.enable = true;

    programs.ghostty.enable = true;
    xdg.terminal-exec = {
      enable = true;
      settings = {
        default = [ "ghostty.desktop" ];
      };
    };

    firefox = {
      enable = true;
      enablePsd = true;
    };
  };
}
