self: pkgs: {
  google-chrome = pkgs.google-chrome.override {
    commandLineArgs = "--ssl-version-min=tls1 --cipher-suite-blacklist=0x009e,0x0033,0x0032,0x000a,0x0005,0x0004,0xc007,0xc011,0x009c,0x002f --disk-cache-dir=/tmp/cache";
  };
  chromium = pkgs.chromium.override {
    commandLineArgs = "--ssl-version-min=tls1 --cipher-suite-blacklist=0x009e,0x0033,0x0032,0x000a,0x0005,0x0004,0xc007,0xc011,0x009c,0x002f --disk-cache-dir=/tmp/cache";
  };
}
