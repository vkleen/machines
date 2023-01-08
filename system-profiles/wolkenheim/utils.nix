{ lib, flake, ... }:
rec {
  inherit (flake.inputs.utils.lib) private_address linkLocal_address linkLocal_address6;
  inherit (flake.inputs.utils.lib.ints) hexToInt;

  hostIds = flake.inputs.macname.idTable."wolkenheim.kleen.org";

  hostASN = fabric: host:
    ASN fabric.hosts.${host}.AS;

  hostAS = fabric: host:
    fabric.AS.${fabric.hosts.${host}.AS};

  otherAS = fabric: host:
    lib.attrsets.filterAttrs (n: _: n != fabric.hosts.${host}.AS) fabric.AS;

  ASN = AS:
    4204871356 + (flake.inputs.macname.computeHash16 AS);

  intfName = host: intf: let
      maxLength = 15;
      intfLength = lib.strings.stringLength intf;

      limitedHost = lib.strings.substring 0 (maxLength - intfLength - 2) host;
    in "${limitedHost}${lib.strings.optionalString (intf != "_") "-${intf}"}";

  linkName = host: l: intfName (linkRemote host l).host l.from.intf;

  linkRemote = host: l: if linkIsFrom host l
                          then l.to
                          else l.from;
  linkLocal = host: l: if linkIsFrom host l
                          then l.from
                          else l.to;

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

  bfdListenPort = ip4Ns:
    3784 + ip4Ns;

  linkIsTo = h: a: a.to.host == h;
  linkIsFrom = h: a: a.from.host == h;

  linksFrom = host: normalizedLinks:
    lib.lists.filter (l: linkIsFrom host l) normalizedLinks;

  linksTo = host: normalizedLinks:
    lib.lists.filter (l: linkIsTo host l) normalizedLinks;

  linksInvolving = host: normalizedLinks:
    linksFrom host normalizedLinks ++ linksTo host normalizedLinks;
}
