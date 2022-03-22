{ config, flake, hostName, pkgs, lib, ... }:
with import ./utils.nix { inherit lib flake; }; let
  inherit (config.networking.wolkenheim) fabric;
  normalizedLinks = normalize fabric.wg-links;
  remote = linkRemote hostName;
  name = linkName hostName;

  linkListenAddresses4 = lib.lists.map
    (l: linkLocal_address (ip4Namespace fabric normalizedLinks l.linkId) hostName)
    (linksInvolving hostName normalizedLinks);
  linkListenAddresses = lib.lists.map
    (l: linkLocal_address6 l.linkId hostIds.${hostName})
    (linksInvolving hostName normalizedLinks);
  makePeer = l: lib.attrsets.nameValuePair
    "${name l}"
    {
      address = "[${linkLocal_address6 l.linkId hostIds.${(remote l).host}}%${name l}]:3784";
      port = 3784;
      interval = l.bfdInterval or 100;
      detectionMultiplier = l.bfdDetectionMultiplier or 5;
    };

  bfdConfig = (pkgs.formats.yaml {}).generate "bfdd.yaml" {
    listen = linkListenAddresses;
    peers = lib.attrsets.listToAttrs (lib.lists.map makePeer (linksInvolving hostName normalizedLinks));
  };

  wg-link-units = lib.lists.map (l: "wireguard-${name l}.service") (linksInvolving hostName normalizedLinks);
in {
  environment.systemPackages = [
    pkgs.bfd
  ];
  system.build.bfdConfig = bfdConfig;
  networking.firewall.interfaces = lib.attrsets.listToAttrs (lib.lists.map
    (l: lib.attrsets.nameValuePair "${name l}" {
      allowedUDPPorts = [3784];
    })
    (linksInvolving hostName normalizedLinks));
  systemd.services.bfdd = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ] ++ wg-link-units;
    requires = wg-link-units;
    script = ''
      exec ${pkgs.bfdd}/bin/bfdd -s "$RUNTIME_DIRECTORY/bfdd.sock" -c "${bfdConfig}"
    '';
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RuntimeDirectoryMode = "0700";
      RuntimeDirectory = "bfdd";
      DynamicUser = false;
      User = "frr";
      Group = "frr";
    };
  };

  systemd.services.bfd-monitor = {
    wantedBy = [ "multi-user.target" ];
    after = [ "bfdd.service" "gobgpd.service" ];
    bindsTo = [ "bfdd.service" "gobgpd.service" ];
    script = ''
      exec ${flake.inputs.bfd-monitor.packages.${config.nixpkgs.system}.bfd-monitor}/bin/bfd-monitor
    '';
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      DynamicUser = false;
      User = "frr";
      Group = "frr";
    };
  };
}
