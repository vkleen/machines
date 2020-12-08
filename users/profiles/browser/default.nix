{pkgs, lib, nixos, config, ...}:
let
  cfg = config.browser;

  chromium-pkg = (pkgs.chromium.override {
    commandLineArgs = "--disk-cache-dir=/tmp/cache --enable-feature=UseOzonePlatform --ozone-platform=wayland --use-cmd-decoder=validating --use-gl=desktop";
    enableWideVine = true;
    enableVaapi = false;
  });

  firejail-chromium = pkgs.writeShellScriptBin "chromium" ''
    exec ${nixos.security.wrapperDir}/firejail --ignore=nodbus --whitelist="${config.home.homeDirectory}/dl" ${cfg.chromium-unwrapped}/bin/chromium-browser "$@"
  '';

  foreflight-chromium = pkgs.writeShellScriptBin "foreflight" ''
    exec ${nixos.security.wrapperDir}/firejail --blacklist="${config.home.homeDirectory}/.config/chromium" --whitelist="${config.home.homeDirectory}/.foreflight" --ignore=nodbus ${cfg.chromium-unwrapped}/bin/chromium-browser --new-window --user-data-dir="${config.home.homeDirectory}/.foreflight" "https://plan.foreflight.com"
  '';
in {
  options = {
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
      foreflight-chromium
    ];
  };
}
