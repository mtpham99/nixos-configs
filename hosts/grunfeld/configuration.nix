{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware
    ./sops.nix
    ./home.nix

    ../../modules/nixos/desktop-environment
    {
      desktop-environment = {
        enable = true;
        desktop = "hyprland";
      };
    }
  ];

  config = {
    nix =
      let
        flakeInputs = lib.filterAttrs (_name: input: input.flake or true) inputs;
      in
      {
        package = pkgs.nix;
        settings.trusted-users = [
          "root"
          "@wheel"
        ];
        settings.experimental-features = "nix-command flakes";

        settings.substituters = [
          "https://cache.nixos.org"
          "https://nix-community.cachix.org"
        ];
        settings.trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];

        channel.enable = false;
        settings.accept-flake-config = true;
        settings.flake-registry = "";
        registry = lib.mapAttrs (_name: input: { flake = input; }) flakeInputs;

        nixPath = lib.mapAttrsToList (name: _input: "${name}=flake:${name}") flakeInputs;
        settings.nix-path = config.nix.nixPath;
        settings.use-xdg-base-directories = true;

        settings.auto-optimise-store = true;
        gc = {
          automatic = true;
          dates = "monthly";
        };
      };

    boot = {
      kernelPackages = pkgs.linuxPackages_latest;

      loader = {
        systemd-boot = {
          enable = true;
          consoleMode = "auto";
        };
        efi.canTouchEfiVariables = true;
      };

      kernelParams = [
        # "quiet"
        # "splash"

        "zswap.enabled=1"
        "zswap.compressor=zstd"
      ];
    };

    # see https://github.com/sched-ext/scx
    services.scx = {
      enable = true;
      scheduler = "scx_bpfland";
    };

    networking = {
      hostName = "grunfeld";
      networkmanager.enable = true;
      firewall = {
        enable = true;
        allowedTCPPorts = [ ];
        allowedUDPPorts = [ ];
      };
    };
    services.openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    environment = {
      shells = [ pkgs.bashInteractive ];

      systemPackages = [
        pkgs.htop
        pkgs.nvtopPackages.full
        pkgs.duf
        pkgs.lsof

        pkgs.pciutils

        pkgs.nmap
        pkgs.tcpdump
        pkgs.bind.dnsutils

        pkgs.fzf

        pkgs.tmux
        pkgs.neovim

        pkgs.nixfmt-rfc-style
        pkgs.nix-output-monitor
      ];

      shellAliases = {
        ls = "ls --color=auto";
        grep = "grep --color=auto";
        diff = "diff --color=auto";
        watch = "watch --color";
        mkdir = "mkdir -pv";
        mount = "mount | column -t";
      };
    };

    i18n.defaultLocale = "en_US.UTF-8";
    i18n.supportedLocales = [ "all" ];
    time.timeZone = "America/Chicago";

    users = {
      mutableUsers = false;
      users = {
        "mtpham" = {
          name = "mtpham";
          description = "Matthew T. Pham";
          home = "/home/mtpham";
          isNormalUser = true;
          uid = 1000;
          group = "mtpham";
          extraGroups = [ "wheel" ];
          shell = pkgs.bashInteractive;

          hashedPasswordFile = config.sops.secrets.mtphamUserpass.path;
        };
      };

      groups = {
        "${config.users.users."mtpham".group}" = {
          gid = config.users.users."mtpham".uid;
          members = [ config.users.users."mtpham".name ];
        };
      };
    };

    systemd.tmpfiles.rules =
      let
        mtphamUserName = config.users.users."mtpham".name;
        mtphamGroupName = config.users.users."mtpham".group;
      in
      [
        "d /data/${mtphamUserName} 0700 ${mtphamUserName} ${mtphamGroupName} -"
      ];
    fileSystems."/home/mtpham/tmp" = {
      depends = [ "/home/mtpham" ];
      device = "tmpfs";
      fsType = "tmpfs";
      options = [
        "size=25%"
        "uid=${builtins.toString config.users.users."mtpham".uid}"
        "gid=${builtins.toString config.users.groups."mtpham".gid}"
        "mode=0700"
        "nodev"
      ];
    };

    powerManagement = {
      enable = true;
      cpuFreqGovernor = "powersave";
    };

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      jack.enable = true;
    };

    # https://wiki.nixos.org/wiki/FAQ/When_do_I_update_stateVersion
    system.stateVersion = "25.05";
  };
}
