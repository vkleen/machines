{pkgs, lib, nixos, config, ...}:
let
  cfg = config.browser;

  firefox-pkg = pkgs.firefox-wayland;
  firejail-firefox = pkgs.writeShellScriptBin "firefox" ''
    exec ${nixos.security.wrapperDir}/firejail --ignore=nodbus --whitelist="${config.home.homeDirectory}/dl" ${cfg.firefox-unwrapped}/bin/firefox
  '';

  chromium-pkg = (pkgs.chromium.override {
    commandLineArgs = "--disk-cache-dir=/tmp/cache";
    # commandLineArgs = "--disk-cache-dir=/tmp/cache --enable-features=UseOzonePlatform --ozone-platform=wayland";
    # enableWideVine = true;
    # enableVaapi = true;
  });

  firejail-chromium = pkgs.writeShellScriptBin "chromium" ''
    exec ${nixos.security.wrapperDir}/firejail --ignore=nodbus --whitelist="${config.home.homeDirectory}/dl" ${cfg.chromium-unwrapped}/bin/chromium-browser "$@"
  '';

  foreflight-chromium = pkgs.writeShellScriptBin "foreflight" ''
    exec ${nixos.security.wrapperDir}/firejail --blacklist="${config.home.homeDirectory}/.config/chromium" --whitelist="${config.home.homeDirectory}/.foreflight" --ignore=nodbus ${cfg.chromium-unwrapped}/bin/chromium-browser --new-window --user-data-dir="${config.home.homeDirectory}/.foreflight" "https://plan.foreflight.com"
  '';

  zoomy-chromium = pkgs.writeShellScriptBin "zoomy-chromium" ''
    ${cfg.chromium-unwrapped}/bin/chromium-browser --new-window --user-data-dir="${config.home.homeDirectory}/.zoomy" "https://uni-due.zoom.us"
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
      foreflight-chromium
      zoomy-chromium
    ];
  };
}
