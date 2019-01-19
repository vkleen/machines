{config, pkgs, ...}:
{
  services.tor = {
    enable = true;
    client = {
      enable = true;
    };
    relay = {
      enable = false;
    };
    controlPort = 9051;
    extraConfig = ''
      CookieAuthentication 1
      # UseBridges 1
      # Bridge obfs4 76.8.60.100:443 B6F2EEFCDED6A4C2713D7B1C4F7903EEA05AB06D cert=kKUffgIAKJKD8G7vNAayVrOdVF23JMbnJGSodB8t6NuL+PlLi/LCpEn5nwxm9l05AV3jCg iat-mode=0
      # Bridge obfs4 185.167.76.155:443 9AFF32DB4662C619E91EE4BECC481AEC103AA5F7 cert=XfxW/3xiDQxrgekiYNNXcw6M1KfBJXIwt9Fo1OWuE0mrZn+1PozowAWPeNrg4rwTVvIWSw iat-mode=0
      # Bridge obfs4 195.201.103.38:45883 6918ABB45999C39C3D9386E71CA93FC9A154ED08 cert=mqau24JMY9DPUA67ihGBnWqUGrVzf8WimxRVjc8w0UIVWFMS4T2qEw+nw9M4w1uqFWgTJw iat-mode=0
      # ClientTransportPlugin obfs4 exec ${pkgs.obfs4proxy}/bin/obfs4proxy
    '';
  };
}
