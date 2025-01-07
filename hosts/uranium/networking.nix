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
      "30-eno5np0" = {
        matchConfig.Path = "pci-0000:5d:00.0";
        extraConfig = ''
          [Link]
          SR-IOVVirtualFunctions=5
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
          [SR-IOV]
          VirtualFunction=4
          VLANId=11
          VLANProtocol=802.1Q
          MACSpoofCheck=yes
          MACAddress=32:9e:08:68:b5:7a
          LinkState=yes
          Trust=no
        '';
      };
      "30-eth1" = {
        matchConfig.Path = "pci-0000:5d:00.1";
        linkConfig = {
          Name = "eth1";
          MACAddress = "04:09:73:e3:16:31";
        };
      };
      "30-intucorp" = {
        matchConfig.Path = "pci-0000:5d:00.2";
        linkConfig = {
          Name = "intucorp";
          MACAddress = "32:9e:08:68:b5:76";
        };
      };
      "30-intuitive" = {
        matchConfig.Path = "pci-0000:5d:00.4";
        linkConfig = {
          Name = "intuitive";
          MACAddress = "32:9e:08:68:b5:78";
        };
      };
      "30-robot" = {
        matchConfig.Path = "pci-0000:5d:00.5";
        linkConfig = {
          Name = "robot";
          MACAddress = "32:9e:08:68:b5:79";
        };
      };
      "30-xplane" = {
        matchConfig.Path = "pci-0000:5d:00.3";
        linkConfig = {
          Name = "xplane";
          MACAddress = "32:9e:08:68:b5:77";
        };
      };
      "30-windows" = {
        matchConfig.Path = "pci-0000:5d:00.6";
        linkConfig = {
          Name = "windows";
          MACAddress = "32:9e:08:68:b5:7a";
        };
      };
    };
    networks = {
      "30-eth1" = {
        matchConfig.Path = "pci-0000:5d:00.1";
        networkConfig = {
          DHCP = "no";
          LinkLocalAddressing = false;
          KeepConfiguration = true;
        };
      };
      "30-eth0" = {
        matchConfig.Path = "pci-0000:5d:00.0";
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
