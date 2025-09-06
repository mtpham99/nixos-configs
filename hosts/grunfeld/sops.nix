{
  inputs,
  config,
  ...
}:
let
  mtphamUser = config.users.users."mtpham";
in
{
  sops = {
    gnupg.home = null;
    gnupg.sshKeyPaths = [ ];
    age.sshKeyPaths = [ ];
    age.keyFile = "/etc/sops/age/keys.txt";
    defaultSopsFormat = "yaml";

    secrets = {
      mtphamUserpass = {
        key = "users/mtpham";
        sopsFile = inputs.secrets + "/sops/grunfeld/userpass.yaml";
        neededForUsers = true;
      };

      luksKeyFileNixosFS = {
        format = "binary";
        # key = "";
        sopsFile = inputs.secrets + "/sops/grunfeld/luks/nixosfs-keyslot1.bin";
        path = "/etc/cryptsetup-keys.d/nixosfs-keyslot1.bin";
        mode = "0400";
      };
      luksKeyFileDataFS = {
        format = "binary";
        # key = "";
        sopsFile = inputs.secrets + "/sops/grunfeld/luks/datafs-keyslot1.bin";
        path = "/etc/cryptsetup-keys.d/datafs-keyslot1.bin";
        mode = "0400";
      };
    };
  };
}
