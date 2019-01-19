{pkgs, lib, ...}:
{
  programs.chromium = {
    enable = false;
    package = (pkgs.chromium.override {
      channel = "beta";
      pulseSupport = true;
      commandLineArgs = "--ssl-version-min=tls1 --cipher-suite-blacklist=0x009e,0x0033,0x0032,0x000a,0x0005,0x0004,0xc007,0xc011,0x009c,0x002f --disk-cache-dir=/tmp/cache";
    });
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm"
    ];
  };

  home.packages =
    let fcfg = lib.setAttrByPath ["firefox-devedition-bin-unwrapped"] {
          enableAdobeFlash = false;
          enableGoogleTalkPlugin = false;
          icedtea = false;
        };

        wrapper = pkgs.wrapFirefox.override {
          config = fcfg;
        };
    in [ (wrapper pkgs.firefox-devedition-bin-unwrapped { browserName = "firefox"; }) ];
}
