{
  inputs,
  config,
  ...
}:

{
  imports = [
    # disko (disks, filesystems, partitions, etc.)
    (import ./disko.nix {
      luksKeyFileNixosFS = config.sops.secrets.luksKeyFileNixosFS.path;
      luksKeyFileDataFS = config.sops.secrets.luksKeyFileDataFS.path;
    })

    # create mountpoints and shared data dir
    {
      # see `man tmpfiles.d`
      systemd.tmpfiles.rules = [
        "d /mnt         0755 root root - -"

        "d /data        0755 root root - -"
        "d /data/shared 1777 root root - -"
      ];
    }

    # nixos-hardware
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme-gen2

    # nvidia
    ./nvidia.nix
  ];

  config = {
    # NOTE: for later -- build everything from source
    # nix.settings.substitute = false; # disable binary caches
    # system.includeBuildDependencies = true; # keep build source files

    # NOTE: first time compile needs `system-feature` manually enabled
    # i.e. `nixos-rebuild build --option system-feature "gccarch-$(cat /sys/devices/cpu/caps/pmu_name) big-parallel nixos-test kvm" ...`
    # nixpkgs = {
    #   hostPlatform = {
    #     system = "x86_64-linux";
    #     gcc.arch = "skylake";
    #     gcc.tune = "skylake";
    #   };
    #   config = {
    #     # TODO: make an optimized stdenv/toolchain
    #     #   - ccache
    #     #   - compile flags
    #     #   - etc.
    #     # replaceStdenv = { pkgs }: pkgs.fastStdenv;
    #   };
    # };

    # facter hardware configuration
    # see `nix run .#nixosConfigurations.<configurationName>.config.facter.debug.nvd`
    facter.reportPath = ./facter.json;

    # udev symlinks for consistent /dev/dri/${CARD} paths
    services.udev.extraRules = let
      nvidiaGpuId = "0000:01:00.0";
      nvidiaGpuName = "nvidia-gtx-1650-maxq";
      intelGpuId = "0000:00:02.0";
      intelGpuName = "intel-uhd-graphics-630";
    in ''
      # Create /dev/dri/''${CARD} symlink
      KERNEL=="card*", KERNELS=="${nvidiaGpuId}", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/${nvidiaGpuName}"
      KERNEL=="card*", KERNELS=="${intelGpuId}", SUBSYSTEM=="drm", SUBSYSTEMS=="pci", SYMLINK+="dri/${intelGpuName}"
    '';

    services.undervolt = {
      enable = true;
      coreOffset = -110;
      gpuOffset = -110;
    };

    services.fwupd.enable = true;
    services.fstrim.enable = true;
    services.thinkfan.enable = true;

    services.blueman.enable = true;
    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };

    services.snapper =
      let
        mtphamUser = config.users.users."mtpham";
      in
      {
        configs = {
          "mtpham" = {
            SUBVOLUME = mtphamUser.home;
            ALLOW_USERS = [ mtphamUser.name ];
            TIMELINE_CREATE = true;
            TIMELINE_CLEANUP = true;
          };
        };
      };
  };
}
