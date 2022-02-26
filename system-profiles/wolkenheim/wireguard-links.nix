{ config, lib, flake, hostName, pkgs, ...}:
with import ./utils.nix { inherit lib flake; }; let
  inherit (config.networking.wolkenheim) fabric;
  normalizedLinks = normalize fabric.wg-links;

  name = linkName hostName;
  remote = linkRemote hostName;
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
    systemd.network = {
      netdevs = lib.attrsets.listToAttrs (lib.lists.map
        (l: let
          ip6Ns = l.linkId;
          ip4Ns = ip4Namespace fabric normalizedLinks ip6Ns;
        in lib.attrsets.nameValuePair "40-${name l}" {
          netdevConfig = {
            Name = name l;
            Kind = "wireguard";
            MTUBytes = "1412";
          };
          wireguardConfig = {
            PrivateKeyFile = "/run/agenix/${hostName}";
          } // lib.attrsets.optionalAttrs (linkIsTo hostName l) {
            ListenPort = linkListenPort ip4Ns;
          };
          wireguardPeers = [
            { wireguardPeerConfig = {
              PublicKey = lib.strings.removeSuffix "\n" (builtins.readFile (
                ../../wireguard + "/${(remote l).host}.pub"));
              AllowedIPs = [ "0.0.0.0/0" "::/0" ];
            } // lib.attrsets.optionalAttrs (linkIsFrom hostName l) {
              Endpoint = "${(remote l).host}.kleen.org:${builtins.toString (linkListenPort ip4Ns)}";
            }; }
          ];
          extraConfig = ''
            [Match]
          '';
        })
        (linksInvolving hostName normalizedLinks));
      networks = lib.attrsets.listToAttrs (lib.lists.map
        (l: let
          ip6Ns = l.linkId;
          ip4Ns = ip4Namespace fabric normalizedLinks ip6Ns;
          localAS = hostAS fabric hostName;
        in lib.attrsets.nameValuePair "40-${name l}" ({
          name = name l;
          address = [
            "${linkLocal_address ip4Ns hostName}/24"
            "${private_address6 ip6Ns hostIds.${hostName}}/96" 
          ];
          extraConfig = ''
            [Neighbor]
            Address=${private_address6 ip6Ns hostIds.${(remote l).host}}
            LinkLayerAddress=${private_address6 ip6Ns hostIds.${(remote l).host}}
          '';
        } // lib.attrsets.optionalAttrs (linkIsFrom hostName l && localAS.announcePublic) { # HACK: change me to zebra
          routingPolicyRules = [
            { routingPolicyRuleConfig = { Table = ip4Ns; From = localAS.public4; Priority = ip4Ns; }; }
            { routingPolicyRuleConfig = { Table = ip4Ns; From = localAS.public6; Priority = ip4Ns; }; }
          ];
          routes = [
            { routeConfig = { Gateway = "${linkLocal_address ip4Ns (remote l).host}"; Table = ip4Ns; }; }
            { routeConfig = { Gateway = "${private_address6 ip6Ns hostIds.${(remote l).host}}"; Table = ip4Ns; }; }
          ];
        }))
        (linksInvolving hostName normalizedLinks));
    };
  };
}
