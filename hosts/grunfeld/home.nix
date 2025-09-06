{
  inputs,
  ...
}:

{
  home-manager = {
    useGlobalPkgs = true; # see `inputs.home-manager.inputs.follows.nixpkgs`
    useUserPackages = false; # enables `users.users.<name>.packages`
    extraSpecialArgs = { inherit inputs; };

    backupFileExtension = "bak";
    verbose = true;

    users = {
      "mtpham" = ../../homes/mtpham;
    };
  };
}
