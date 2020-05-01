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
in {
  home.packages = [
    update-chlorine-boot
    wx
  ];
}
