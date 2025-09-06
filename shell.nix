{
  pkgs,
  ...
}:

pkgs.mkShell {
  packages = [
    pkgs.sops
    pkgs.disko
    pkgs.nixos-anywhere

    pkgs.nixfmt-rfc-style
    pkgs.nix-output-monitor

    pkgs.git
    pkgs.gh
    pkgs.gnupg
    pkgs.pinentry-curses

    pkgs.neovim
  ];

  shellHook = ''
    # env vars
    export EDITOR="${pkgs.neovim}/bin/nvim";
    export VISUAL="${pkgs.neovim}/bin/nvim";

    # aliases
    alias nix="nix --experimental-features 'nix-command flakes'"

    # gnupg setup
    gpgconf --kill all >/dev/null 2>&1
    gpg-agent --daemon --pinentry-program='${pkgs.pinentry-curses}/bin/pinentry' >/dev/null 2>&1
  '';
}
