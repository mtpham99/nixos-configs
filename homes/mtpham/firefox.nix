{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.firefox;
in
{
  options = {
    firefox = {
      enable = lib.mkEnableOption "firefox";
      enablePsd = lib.mkEnableOption "profile-sync-daemon";
    };
  };

  config = lib.mkIf cfg.enable {
    services.psd.enable = cfg.enablePsd;

    programs.firefox = {
      enable = true;

      policies = {
        DisableTelemetry = true;
        DisableAccounts = true;
        DisableFirefoxAccounts = true;
        DisplayBookmarksToolbar = "newtab";
        ExtensionUpdate = true;
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
      };

      profiles = {
        "${config.home.username}" = {
          id = 0;
          isDefault = true;

          search = {
            default = "ddg";
            privateDefault = "ddg";
          };

          extensions.packages =
            let
              firefox-addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
            in
            [
              firefox-addons.bitwarden
              firefox-addons.libredirect
              firefox-addons.darkreader
              firefox-addons.xbrowsersync
              firefox-addons.ublock-origin
              firefox-addons.metamask
            ];
        };
      };
    };
  };
}
