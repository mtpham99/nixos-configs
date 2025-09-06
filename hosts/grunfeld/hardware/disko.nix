{
  luksKeyFileNixosFS,
  luksKeyFileDataFS,
  ...
}:
let
  ramSize = "32498448K"; # see `free --kibi`
  swapSize = ramSize;

  # btrfs subvolumes
  btrfsOpts = [
    "compress=zstd:1"
    "noatime"
  ];

  rootSubvols = {
    "@" = {
      mountpoint = "/";
      mountOptions = btrfsOpts;
    };
    "@var".mountpoint = "/var";
    "@srv".mountpoint = "/srv";
    "@root".mountpoint = "/root";

    # TODO: consider moving `/nix` to xfs disk and using `noatime`
    "@nix".mountpoint = "/nix";
  };

  userSubvols = {
    "@mtpham".mountpoint = "/home/mtpham";
    "@mtpham/.snapshots" = { };
  };

  # partitions
  espPart = {
    label = "esp";
    type = "EF00"; # efi system partition (esp)
    size = "512M";
    content = {
      type = "filesystem";
      extraArgs = [
        "-n"
        "EFI"
      ];
      format = "vfat";
      mountpoint = "/boot";
      mountOptions = [ "umask=0077" ];
    };
  };

  swapLuksPart = {
    label = "swap-luks";
    type = "8309"; # luks partition (luks)
    size = swapSize;
    content = {
      name = "swap";
      type = "luks";
      extraFormatArgs = [
        "--label"
        "SWAP_LUKS"
      ];
      additionalKeyFiles = [ luksKeyFileNixosFS ];
      content = {
        type = "swap";
        extraArgs = [
          "-L"
          "SWAP"
        ];
        discardPolicy = "both"; # see `man swapon(8)`
        resumeDevice = true;
      };
    };
  };

  rootLuksPart = {
    label = "root-luks";
    type = "8309"; # luks partition (luks)
    size = "100%";
    content = {
      name = "root";
      type = "luks";
      extraFormatArgs = [
        "--label"
        "ROOT_LUKS"
      ];
      additionalKeyFiles = [ luksKeyFileNixosFS ];
      content = {
        type = "btrfs";
        extraArgs = [
          "-L"
          "ROOT"
        ];
        subvolumes = rootSubvols // userSubvols;
      };
    };
  };

  dataLuksPart = {
    label = "data-luks";
    type = "8309"; # luks partition (luks)
    size = "100%";
    content = {
      name = "data";
      type = "luks";
      extraFormatArgs = [
        "--label"
        "DATA_LUKS"
      ];
      additionalKeyFiles = [ luksKeyFileDataFS ];
      content = {
        type = "filesystem";
        extraArgs = [
          "-L"
          "DATA"
        ];
        format = "xfs";
        mountpoint = "/data";
      };
    };
  };
in
{
  disko.devices = {
    disk = {
      rootDisk = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_980_1TB_S64ANJ0R616343T";
        content = {
          type = "gpt";
          partitions = {
            esp = espPart;
            swap_luks = swapLuksPart;
            root_luks = rootLuksPart;
          };
        };
      };

      dataDisk = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-WDC_PC_SN730_SDBQNTY-512G-1001_20153E801841";
        content = {
          type = "gpt";
          partitions = {
            data_luks = dataLuksPart;
          };
        };
      };
    };

    nodev = {
      tmp = {
        fsType = "tmpfs";
        mountpoint = "/tmp";
        mountOptions = [
          "size=50%"
          "nosuid"
          "nodev"
        ];
      };
    };
  };
}
