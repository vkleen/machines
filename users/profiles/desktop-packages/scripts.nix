{ pkgs, nixos, ... }:
let update-chlorine-boot = pkgs.writeScriptBin "update-chlorine-boot" ''
      #!${pkgs.stdenv.shell}
      ssh -t chlorine -- update-boot
      scp root@chlorine:/boot/\* $HOME/machines/chlorine/boot/
      chmod 644 $HOME/machines/chlorine/boot/*
    '';

    wx = pkgs.writeScriptBin "wx" ''
      #!${pkgs.stdenv.shell}
      station=''${1:-EDDL}
      token="j2FnxQRDqozXVbYhpEv_tncUI4oKgAT75HCbTnRB5Ig"

      curl --header "Authorization: Token ''${token}" \
           "https://avwx.rest/api/taf/''${station}" "https://avwx.rest/api/metar/''${station}" 2>/dev/null \
                | jq -r '.raw'
    '';

    update-envrc = pkgs.writeScriptBin "update-envrc" ''
      #!${pkgs.stdenv.shell}
      SHELLNIX=''${1:-shell.nix}

      DIRENV=${pkgs.direnv}/bin/direnv

      mkdir -p .gcroots

      nix-instantiate "''${SHELLNIX}" --indirect --add-root "$PWD"/.gcroots/shell.drv
      nix-shell "$(readlink "$PWD"/.gcroots/shell.drv)" --run 'unset ''${!SSH_@} ''${!DIRENV_@} shellHook TEMP TEMPDIR TMP TMPDIR SSL_CERT_FILE NIX_SSL_CERT_FILE ''${!DBUS@} ''${!DESKTOP@} ''${!XDG@} ''${!TMUX@} I3SOCK TERM && '"$DIRENV"' dump bash > '"''${2:-.envrc.cache}"' '
    '';

    update-flake-cache = pkgs.writeScriptBin "update-flake-cache" ''
      #!${pkgs.stdenv.shell}
      : ''${XDG_CACHE_HOME:=$HOME/.cache}
      pwd_hash=$(basename $PWD)-$(echo -n $PWD | b2sum | cut -d ' ' -f 1)
      direnv_layout_dir=$XDG_CACHE_HOME/direnv/layouts/$pwd_hash
      mkdir -p $direnv_layout_dir

      nix print-dev-env > "$direnv_layout_dir/flake-cache"
    '';
in {
  home.packages = [
    update-chlorine-boot
    wx
    update-envrc update-flake-cache
  ];
}
