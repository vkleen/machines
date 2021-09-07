{ pkgs, config, ...}:
let
  moduleList = builtins.fromJSON (builtins.readFile (pkgs.runCommandCC "crypto-modules" { buildInputs = with pkgs; [ jq ]; } ''
    echo "[]" > $out
    while IFS= read -r -d $'\0' file; do
      unpacked=$(basename "''${file}" .xz)
      xz -cd "''${file}" > "''${unpacked}"

      module=$(readelf -Wp .gnu.linkonce.this_module "''${unpacked}" | sed -rn '/\[\s*[0-9]+\] /{ s/^[^]]*\]\s*//; p; q; }')
      jq '. + [ $name ]' $out --arg name "''${module}" > out.json && mv out.json $out
    done < <(find ${config.system.modulesTree}/lib/modules/*/kernel{,/arch/*}/crypto -iname '*.ko.xz' -print0 | sort -z)
  ''));
in {
  boot.initrd.luks.cryptoModules = moduleList ++ [
    "encrypted_keys"
  ];
}

