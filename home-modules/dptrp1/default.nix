{ config, pkgs, lib, nixos, ... }:
let
  cfg = config.programs.dptrp1;

  dptrp1-address = "fe80::ae89:95ff:fef8:15a2";
  dptrp1-bt-address = "AC_89_95_F8_15_A2";
  dptrp1 = pkgs.writeShellScriptBin "dptrp1" ''
    set -e
    extract_interface() {
      ${pkgs.gawk}/bin/awk '{gsub("\"", "", $2); print $2}'
    }

    connect() {
      interface=$(${pkgs.systemd}/bin/busctl call org.bluez /org/bluez/hci0/dev_${dptrp1-bt-address} org.bluez.Network1 Connect s nap | extract_interface)
      tries=0
      until [[ $tries -eq 5 ]] || ${nixos.security.wrapperDir}/ping -c1 -I "$interface" ${dptrp1-address} >/dev/null; do
        ${pkgs.coreutils}/bin/sleep 1
        tries=$((tries + 1))
      done
      printf "%s" "$interface"
    }

    connected=$(${pkgs.systemd}/bin/busctl get-property org.bluez /org/bluez/hci0/dev_${dptrp1-bt-address} org.bluez.Network1 Connected)
    case "$connected" in
      *false)
        interface=$(connect)
        ;;
      *true)
        interface=$(${pkgs.systemd}/bin/busctl get-property org.bluez /org/bluez/hci0/dev_${dptrp1-bt-address} org.bluez.Network1 Interface | extract_interface)
        ;;
      *)
        exit 1
        ;;
    esac
    ${pkgs.dpt-rp1-py}/bin/dptrp1 --client-id /run/secrets/dptrp1 --key /run/secrets/dptrp1.key --addr "[${dptrp1-address}%$interface]" "''${@}"
  '';
in {
  options = {
    programs.dptrp1.pkg = lib.mkOption {
      default = dptrp1;
      type = lib.types.package;
    };
  };
  config = {
    home.packages = [
      cfg.pkg
    ];
  };
}
