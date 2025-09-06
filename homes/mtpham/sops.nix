{
  inputs,
  config,
  ...
}:

{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  config = {
    sops = {
      gnupg.home = null;
      gnupg.sshKeyPaths = [ ];
      age.sshKeyPaths = [ ];
      age.keyFile = "/etc/sops/age/keys.txt";
      defaultSopsFormat = "yaml";

      secrets = {
        mtphamSSHPublicKey = {
          key = "ssh/mtpham_grunfeld/public_key";
          sopsFile = inputs.secrets + "/sops/ssh.yaml";
          path = config.home.homeDirectory + "/.ssh/mtpham_grunfeld.pub";
          mode = "0400";
        };
        mtphamSSHPrivateKey = {
          key = "ssh/mtpham_grunfeld/private_key";
          sopsFile = inputs.secrets + "/sops/ssh.yaml";
          path = config.home.homeDirectory + "/.ssh/mtpham_grunfeld";
          mode = "0400";
        };
      };
    };
  };
}
