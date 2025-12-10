{
  config,
  pkgs,
  lib,
  ...
}:
let
  allowedNvidiaPkgsPred =
    pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
    ];
  allowCudaEulaLicensesPred =
    let
      cudaLicenseNames = [
        "CUDA EULA"
        "cuDNN EULA"
      ];
    in
    pkg:
    lib.all (license: license.free || lib.elem (license.shortName) cudaLicenseNames) (
      lib.toList pkg.meta.license
    );
in
{
  nix.settings = {
    substituters = [ "https://cuda-maintainers.cachix.org" ];
    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg: (allowedNvidiaPkgsPred pkg) || (allowCudaEulaLicensesPred pkg);

  environment.systemPackages = [ pkgs.nvtopPackages.full ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    graphics = {
      enable = true;
      extraPackages = [ pkgs.nvidia-vaapi-driver ];
    };

    nvidia = {
      # NOTE: build error w/ open nvidia kernel module and linuxKernel.packages.linux_6_18.nvidia_x11
      open = true;
      # see https://github.com/NixOS/nixpkgs/issues/467814
      # package = config.boot.kernelPackages.nvidiaPackages.latest;
      package = config.boot.kernelPackages.nvidiaPackages.beta;

      powerManagement = {
        enable = true;
        finegrained = true;
      };
      prime = {
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";

        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    };
  };
}
