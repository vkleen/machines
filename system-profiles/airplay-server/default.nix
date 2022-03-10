{ pkgs, ... }:
{
  # services.avahi = {
  #   enable = true;
  #   wideArea = false;
  #   publish = {
  #     enable = true;
  #     userServices = true;
  #   };
  # };

  #services.usbmuxd = {
  #  enable = true;
  #};

  environment.etc = {
    "systemd/dnssd/raop.dnssd".text = ''
      [Service]
      Name=60F26217597B@bohrium
      Type=_raop._tcp
      Port=9998
      TxtText=ch=2 cn=0,1,2,3 da=true et=0,3,5 vv=2 ft=0x5A7FFFE6 am=AppleTV2,1 md=0,1,2 rhd=5.6.0.0 pw=false sr=44100 ss=16 sv=false tp=UDP txtvers=1 sf=0x4 vs=220.68 vn=65537 pk=b07727d6f6cd6e08b58ede525ec3cdeaa252ad9f683feb212ef8a205246554e7
    '';
    "systemd/dnssd/airplay.dnssd".text = ''
      [Service]
      Name=bohrium
      Type=_airplay._tcp
      Port=9999
      TxtText=deviceid=60f26217597b features=0x5A7FFFE6 flags=0x4 model=AppleTV2,1 pk=b07727d6f6cd6e08b58ede525ec3cdeaa252ad9f683feb212ef8a205246554e7 pi=2e388006-13ba-4041-9a67-25dd4a43d536 srcvers=220.68 vv=2
    '';
  };
}
