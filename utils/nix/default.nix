{ lib, inputs, ... }:
rec {
  ints = import ./ints.nix { inherit lib; };

  elemAtOr = def: xs: n:
    if n >= lib.lists.length xs
    then def
    else lib.lists.elemAt xs n;

  private_address = linkId: machine_id:
    let
      inherit (lib.strings) substring;
      inherit (ints) hexToInt;
      chars12 = substring 0 2 machine_id;
      chars34 = substring 2 2 machine_id;

      octet1 = hexToInt chars12;
      octet2 = hexToInt chars34;
    in
    assert 0 <= linkId && linkId <= 255;
    "10.${builtins.toString linkId}.${builtins.toString octet1}.${builtins.toString octet2}";

  linkLocal_address = linkId: hostName:
    let
      n = inputs.macname.elementTable.${hostName};
    in
    assert 0 <= linkId && linkId <= 255; "169.254.${builtins.toString linkId}.${builtins.toString n}";

  linkLocal_address6 = linkId: machine_id:
    let
      inherit (lib.strings) substring;
      linkIdParts = lib.trivial.toBaseDigits (ints.pow 2 16) linkId;
      linkId0-15 = lib.strings.toLower (lib.trivial.toHexString (elemAtOr 0 linkIdParts 0));
      linkId16-31 = lib.strings.toLower (lib.trivial.toHexString (elemAtOr 0 linkIdParts 1));
      linkId32-47 = lib.strings.toLower (lib.trivial.toHexString (elemAtOr 0 linkIdParts 2));

      chars1234 = substring 0 4 machine_id;
      chars5678 = substring 4 4 machine_id;
    in
    assert 0 <= linkId && linkId <= ints.pow 2 48;
    "fe80:3e0e:b7ec:${linkId0-15}:${linkId16-31}:${linkId32-47}:${chars1234}:${chars5678}";

  getPublic = type: host:
    let
      addresses = inputs.self.nixosConfigurations.${host}.config.system.publicAddresses;
    in
    lib.lists.map (a: a.addr) (lib.lists.filter (a: a.type == type) addresses);

  getPrimaryPublic = type: host:
    lib.lists.head (getPublic type host);

  getAllPublic = host:
    let
      addresses = inputs.self.nixosConfigurations.${host}.config.system.publicAddresses;
    in
    lib.lists.map (a: a.addr) addresses;

  getPublicV4 = getPublic "v4";
  getPublicV6 = getPublic "v6";
  getPrimaryPublicV4 = getPrimaryPublic "v4";
  getPrimaryPublicV6 = getPrimaryPublic "v6";

  mkV4 = a: { type = "v4"; addr = a; };
  mkV6 = a: { type = "v6"; addr = a; };

  mkHosts = flake: hosts: lib.attrsets.listToAttrs (lib.lists.concatMap
    (host: lib.lists.map (a: lib.attrsets.nameValuePair a [ "${host}.kleen.org" ]) (getAllPublic flake host))
    hosts);
}
