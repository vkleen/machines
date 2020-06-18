{pkgs, lib, nixos, config, ...}:
let
  cfg = config.browser;

  firefox-pkg = pkgs.firefox-bin;

  chromium-pkg = (pkgs.chromium.override {
    commandLineArgs = "--ssl-version-min=tls1 --cipher-suite-blacklist=0x009e,0x0033,0x0032,0x000a,0x0005,0x0004,0xc007,0xc011,0x009c,0x002f --disk-cache-dir=/tmp/cache --ozone-platform=wayland";
    useOzone = true;
    enableWideVine = true;
    enableVaapi = true;
  });

  firejail-firefox = pkgs.writeShellScriptBin "firefox" ''
    exec ${nixos.security.wrapperDir}/firejail --ignore=nodbus --whitelist=/home/vkleen/dl ${cfg.firefox-unwrapped}/bin/firefox
  '';

  firejail-chromium = pkgs.writeShellScriptBin "chromium" ''
    exec ${nixos.security.wrapperDir}/firejail --ignore=nodbus --whitelist=/home/vkleen/dl ${cfg.chromium-unwrapped}/bin/chromium-browser "$@"
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
    browser.chromium-unwrapped = lib.mkOption {
      default = chromium-pkg;
      type = lib.types.package;
    };
    browser.chromium = lib.mkOption {
      default = firejail-chromium;
      type = lib.types.package;
    };
  };
  config = {
    programs.chromium = {
      enable = true;
      package = firejail-chromium;
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm"
      ];
    };

    home.packages = [
      cfg.firefox
    ];
  };
}
