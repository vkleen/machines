{pkgs, lib, nixos, config, ...}:
let
  cfg = config.browser;

  firefox-pkg = pkgs.firefox-bin;

  chromium-pkg = (pkgs.chromium.override {
    commandLineArgs = "--disk-cache-dir=/tmp/cache";
    useOzone = true;
    enableWideVine = true;
    enableVaapi = false;
  });

  firejail-firefox = pkgs.writeShellScriptBin "firefox" ''
    exec ${nixos.security.wrapperDir}/firejail --ignore=nodbus --whitelist="${config.home.homeDirectory}/dl" ${cfg.firefox-unwrapped}/bin/firefox
  '';

  firejail-chromium = pkgs.writeShellScriptBin "chromium" ''
    exec ${nixos.security.wrapperDir}/firejail --ignore=nodbus --whitelist="${config.home.homeDirectory}/dl" ${cfg.chromium-unwrapped}/bin/chromium-browser "$@"
  '';

  foreflight-chromium = pkgs.writeShellScriptBin "foreflight" ''
    exec ${nixos.security.wrapperDir}/firejail --blacklist="${config.home.homeDirectory}/.config/chromium" --whitelist="${config.home.homeDirectory}/.foreflight" --ignore=nodbus ${cfg.chromium-unwrapped}/bin/chromium-browser --new-window --user-data-dir="${config.home.homeDirectory}/.foreflight" "https://plan.foreflight.com"
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
    ];
  };
}
