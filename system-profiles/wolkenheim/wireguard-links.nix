{ config, lib, flake, hostName, pkgs, ...}:
with import ./utils.nix { inherit lib flake; }; let
  inherit (flake.inputs.utils.lib) getAllPublic lists attrsets mkHosts getPublicV4;
  inherit (config.networking.wolkenheim) fabric;
  normalizedLinks = normalize fabric.wg-links;

  name = linkName hostName;
  remote = linkRemote hostName;
  local = linkLocal hostName;
in {
  config = {

    age.secrets.${config.networking.hostName} = {
      file = ../../secrets/wireguard + "/${config.networking.hostName}.age";
      mode = "0440";
      owner = "0";
      group = "systemd-network";
    };

    environment.systemPackages = [ pkgs.wireguard-tools ];
    networking.firewall.allowedUDPPorts = lib.lists.map
      (l: linkListenPort (ip4Namespace fabric normalizedLinks l.linkId))
      (linksTo hostName normalizedLinks);

    networking.hosts = mkHosts flake (lists.map
      (l: (remote l).host)
      (linksInvolving hostName normalizedLinks));

    networking.useNetworkd = true;
    networking.wireguard.interfaces = lib.attrsets.listToAttrs (lib.lists.map
      (l: let
        ip6Ns = l.linkId;
        ip4Ns = ip4Namespace fabric normalizedLinks ip6Ns;
        localAS = hostAS fabric hostName;
      in lib.attrsets.nameValuePair (name l) ({
        privateKeyFile = "/run/agenix/${hostName}";
        allowedIPsAsRoutes = false;
        peers = [
          ({
            publicKey = lib.strings.removeSuffix "\n" (builtins.readFile (
              ../../wireguard + "/${(remote l).host}.pub"));
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
          } // lib.attrsets.optionalAttrs (linkIsFrom hostName l) {
            endpoint = "${lists.head (getPublicV4 flake (remote l).host)}:${builtins.toString (linkListenPort ip4Ns)}";
          })
        ];
        socketNamespace = if (local l).intf == "_"
          then "init"
          else "wg_upstream"; # TODO: replace this with (local l).intf when deploying
        interfaceNamespace = "init";
      } // lib.attrsets.optionalAttrs (linkIsTo hostName l) {
        listenPort = linkListenPort ip4Ns;
      }))
      (linksInvolving hostName normalizedLinks));

    systemd.network = {
      networks = lib.attrsets.listToAttrs (lib.lists.map
        (l: let
          ip6Ns = l.linkId;
          ip4Ns = ip4Namespace fabric normalizedLinks ip6Ns;
          localAS = hostAS fabric hostName;
        in lib.attrsets.nameValuePair "40-${name l}" ({
          name = name l;
          address = [
            #"${linkLocal_address ip4Ns hostName}/24"
            "${linkLocal_address6 ip6Ns hostIds.${hostName}}/96" 
          ];
          linkConfig = {
            MTUBytes = "1400";
            RequiredForOnline = "no";
          };
          extraConfig = ''
            [Neighbor]
            Address=${linkLocal_address6 ip6Ns hostIds.${(remote l).host}}
            LinkLayerAddress=${linkLocal_address6 ip6Ns hostIds.${(remote l).host}}
          '';
        }))
        (linksInvolving hostName normalizedLinks));
    };
  };
}
