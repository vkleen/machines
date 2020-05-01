{pkgs, lib, nixos, config, ...}:
let
  cfg = config.browser;

  firefox-pkg = (pkgs.latest.firefox-nightly-bin.override {
    gdkWayland = true;
  });

  firejail-firefox = pkgs.writeShellScriptBin "firefox" ''
    exec ${nixos.security.wrapperDir}/firejail --ignore=nodbus --whitelist=/home/vkleen/dl ${cfg.firefox-unwrapped}/bin/firefox
  '';
in {
  options = {
    browser.firefox = lib.mkOption {
      default = firejail-firefox;
      type = lib.types.package;
    };
    browser.firefox-unwrapped = lib.mkOption {
      default = firefox-pkg;
      type = lib.types.package;
    };
  };
  config = {
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

    home.packages = [
      cfg.firefox
    ];
  };
}
