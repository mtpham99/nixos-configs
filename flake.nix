{
  description = "My NixOS Configurations Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-facter-modules.url = "github:nix-community/nixos-facter-modules";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@github.com/mtpham99/secrets?ref=main";
      flake = false;
    };
    assets = {
      url = "git+ssh://git@github.com/mtpham99/assets?ref=main";
      flake = false;
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland.url = "github:hyprwm/Hyprland";
    walker.url = "github:abenz1267/walker";
  };

  outputs =
    {
      nixpkgs,
      nixos-hardware,
      nixos-facter-modules,
      disko,
      sops-nix,
      home-manager,
      secrets,
      assets,
      firefox-addons,
      hyprland,
      walker,
      ...
    }@inputs:
    let
      supportedSystems = [ "x86_64-linux" ];
      pkgsFor = system: import nixpkgs { inherit system; };
      forAllPkgs = fn: nixpkgs.lib.genAttrs supportedSystems (system: fn (pkgsFor system));
    in
    {
      # `nixos-rebuild { build | switch | ... } --flake .#<hostname>`
      nixosConfigurations = {
        grunfeld = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            nixos-facter-modules.nixosModules.facter
            disko.nixosModules.disko

            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager

            ./hosts/grunfeld/configuration.nix
          ];

          specialArgs = { inherit inputs; };
        };
      };

      # `nix develop`
      devShells = forAllPkgs (pkgs: {
        default = import ./shell.nix { inherit pkgs; };
      });

      # `nix fmt`
      formatter = forAllPkgs (
        pkgs:
        pkgs.treefmt.withConfig {
          runtimeInputs = [ pkgs.nixfmt-rfc-style ];
          settings = pkgs.lib.importTOML ./treefmt.toml;
        }
      );
    };
}
