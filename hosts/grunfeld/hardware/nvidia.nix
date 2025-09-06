{
  config,
  pkgs,
  lib,
  ...
}:
let
  allowedNvidiaPkgsPred = pkg: builtins.elem (lib.getName pkg) [
    "nvidia-x11"
    "nvidia-settings"
  ];
  allowCudaEulaLicensePred = pkg: builtins.elem (pkg.meta.license.shortName) [
    "CUDA EULA"
    "cuDNN EULA"
  ];
in
{
  nix.settings = {
    substituters = [ "https://cuda-maintainers.cachix.org" ];
    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  nixpkgs.config.allowUnfreePredicate = pkg: (allowedNvidiaPkgsPred pkg) || (allowCudaEulaLicensePred pkg);

  environment.systemPackages = [ pkgs.nvtopPackages.full ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware = {
    graphics = {
      enable = true;
      extraPackages = [ pkgs.nvidia-vaapi-driver ];
    };

    nvidia = {
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;

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
