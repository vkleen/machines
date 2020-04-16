{ pkgs, ... }:
let update-boot = pkgs.writeScriptBin "update-boot" ''
      #!${pkgs.stdenv.shell}
      sudo cp $(realpath /nix/var/nix/profiles/system/kernel) /boot/
      sudo cp $(realpath /nix/var/nix/profiles/system/initrd) /boot/
      sudo tee /boot/cmdline >/dev/null <<EOF
        init=$(realpath /nix/var/nix/profiles/system/init) $(< /nix/var/nix/profiles/system/kernel-params)
      EOF
    '';

    update-envrc = pkgs.writeScriptBin "update-envrc" ''
      #!${pkgs.stdenv.shell}
      SHELLNIX=''${1:-shell.nix}

      mkdir -p .gcroots

      ${pkgs.nix}/bin/nix-instantiate "''${SHELLNIX}" --indirect --add-root "$PWD"/.gcroots/shell.drv
      ${pkgs.nix}/bin/nix-shell "$(readlink "$PWD"/.gcroots/shell.drv)" --run 'unset ''${!SSH_@} ''${!DIRENV_@} shellHook TEMP TEMPDIR TMP TMPDIR SSL_CERT_FILE NIX_SSL_CERT_FILE ''${!DBUS@} ''${!DESKTOP@} ''${!XDG@} ''${!TMUX@} I3SOCK TERM && ${pkgs.direnv}/bin/direnv dump bash > '"''${2:-.envrc.cache}"
    '';
in {
  home.packages = [
    update-boot
    update-envrc
  ];
}
