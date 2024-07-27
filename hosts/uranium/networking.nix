{ ... }:
{
  networking = {
    useDHCP = false;
    useNetworkd = true;
    firewall = {
      enable = false;
    };
  };
  systemd.network = {
    enable = true;
    links = {
      "30-eno6np1" = {
        matchConfig.Path = "pci-0000:5d:00.1";
        extraConfig = ''
          [Link]
          SR-IOVVirtualFunctions=4
          [SR-IOV]
          VirtualFunction=0
          VLANId=49
          VLANProtocol=802.1Q
          MACSpoofCheck=yes
          MACAddress=32:9e:08:68:b5:76
          LinkState=yes
          Trust=no
          [SR-IOV]
          VirtualFunction=1
          VLANId=11
          VLANProtocol=802.1Q
          MACSpoofCheck=yes
          MACAddress=32:9e:08:68:b5:77
          LinkState=yes
          Trust=no
          [SR-IOV]
          VirtualFunction=2
          VLANId=48
          VLANProtocol=802.1Q
          MACSpoofCheck=yes
          MACAddress=32:9e:08:68:b5:78
          LinkState=yes
          Trust=no
          [SR-IOV]
          VirtualFunction=3
          VLANId=50
          VLANProtocol=802.1Q
          MACSpoofCheck=no
          MACAddress=32:9e:08:68:b5:79
          LinkState=yes
          Trust=yes
        '';
      };
      "30-intucorp" = {
        matchConfig.Path = "pci-0000:5d:10.1";
        linkConfig = {
          Name = "intucorp";
          MACAddress = "32:9e:08:68:b5:76";
        };
      };
      "30-intuitive" = {
        matchConfig.Path = "pci-0000:5d:10.3";
        linkConfig = {
          Name = "intuitive";
          MACAddress = "32:9e:08:68:b5:78";
        };
      };
      "30-robot" = {
        matchConfig.Path = "pci-0000:5d:10.4";
        linkConfig = {
          Name = "robot";
          MACAddress = "32:9e:08:68:b5:79";
        };
      };
      "30-xplane" = {
        matchConfig.Path = "pci-0000:5d:10.2";
        linkConfig = {
          Name = "xplane";
          MACAddress = "32:9e:08:68:b5:77";
        };
      };
    };
    networks = {
      "30-eno5np0" = {
        matchConfig.Name = "eno5np0";
        linkConfig.RequiredForOnline = "routable";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
        };
      };
      "30-intuitive" = {
        matchConfig.Name = "intuitive";
        linkConfig.RequiredForOnline = "routable";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;
        };
      };
    };
  };
}
