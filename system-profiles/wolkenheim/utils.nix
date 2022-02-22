{ lib, flake, ... }:
rec {
  inherit (flake.inputs.utils.lib) private_address private_address6;
  inherit (flake.inputs.utils.lib.ints) hexToInt;

  hostIds = flake.inputs.macname.idTable."wolkenheim.kleen.org";

  hostAS = fabric: host:
    ASN fabric.hosts.${host}.AS;

  ASN = AS:
    4204871356 + (flake.inputs.macname.computeHash16 AS);

  intfName = host: intf:
    "${host}${lib.strings.optionalString (intf != "_") "-${intf}"}";

  assignIds = linkList:
    lib.lists.map (l: l // { linkId = flake.inputs.macname.computeLinkId l; }) linkList;

  uncheckedIp4NamespaceMap = fabric: normalizedLinks:
    (lib.attrsets.listToAttrs
      (lib.lists.map (l: lib.attrsets.nameValuePair
        (lib.strings.toLower (lib.trivial.toHexString l.linkId))
        (lib.trivial.bitAnd l.linkId 255))
      normalizedLinks))
      // fabric.ip4NamespaceAllocation;

  ip4NamespaceMap = fabric: normalizedLinks: let
    m = uncheckedIp4NamespaceMap fabric normalizedLinks;
  in assert lib.lists.length (lib.attrsets.attrNames m)
         == lib.lists.length (lib.lists.unique (lib.attrsets.attrValues m));
    m;

  ip4Namespace = fabric: normalizedLinks: i: (ip4NamespaceMap fabric normalizedLinks).${lib.strings.toLower (lib.trivial.toHexString i)};

  normalizeTo = l:
    if lib.strings.isString l.to
    then { host = l.to; intf = "_"; }
    else l.to;

  normalize = links:
    assignIds (lib.lists.flatten (lib.attrsets.mapAttrsToList
      (h: intfs: lib.attrsets.mapAttrsToList
        (intf: ls: lib.lists.map 
          (l: l // { from = { host = "${h}"; inherit intf; }; to = normalizeTo l; })
          ls)
        intfs)
      links));

  linkListenPort = ip4Ns:
    51820 + ip4Ns;

  linkIsTo = h: a: a.to.host == h;
  linkIsFrom = h: a: a.from.host == h;

  linksFrom = host: normalizedLinks:
    lib.lists.filter (l: linkIsFrom host l) normalizedLinks;

  linksTo = host: normalizedLinks:
    lib.lists.filter (l: linkIsTo host l) normalizedLinks;

  linksInvolving = host: normalizedLinks:
    linksFrom host normalizedLinks ++ linksTo host normalizedLinks;
}
