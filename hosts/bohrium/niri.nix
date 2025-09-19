{ pkgs, lib, config, options, inputs, ... }:
let
  cfg = config.programs.niri;
  niri-package = pkgs.niri-unstable.overrideAttrs (_: {
    doCheck = false; # Test produce ErrAlreadyInUse, sometimes
  });
in
{
  disabledModules = [ "programs/wayland/niri.nix" ];

  options.programs.niri = {
    enable = lib.mkEnableOption "niri";
    package = lib.mkOption {
      type = lib.types.package;
      default = niri-package;
    };
  };

  config = lib.mkMerge [
    { programs.niri.enable = true; }
    (lib.optionalAttrs (options ? home-manager) {
      home-manager.sharedModules =
        [
          inputs.niri.homeModules.config
          { programs.niri.package = lib.mkForce cfg.package; }
        ]
        ++ lib.optionals (options ? stylix) [ inputs.niri.homeModules.stylix ];
    })
    (lib.mkIf (cfg.enable) (lib.mkMerge [
      {
        environment.systemPackages = [
          cfg.package
          pkgs.xdg-utils
        ];

        xdg.portal = {
          enable = true;
          config = {
            niri = {
              default = [ "gnome" "gtk" ];
              "org.freedesktop.impl.portal.Access" = [ "gtk" ];
              "org.freedesktop.impl.portal.Notification" = [ "gtk" ];
              "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ];
              "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
            };
          };
          extraPortals = lib.mkIf
            (!cfg.package.cargoBuildNoDefaultFeatures || builtins.elem "xdp-gnome-screencast" cfg.package.cargoBuildFeatures)
            [ pkgs.xdg-desktop-portal-gnome ];
          configPackages = [ cfg.package ];
        };

        security.polkit.enable = true;
        services.gnome.gnome-keyring.enable = true;
        systemd.user.services.niri-flake-polkit = {
          description = "PolicyKit Authentication Agent provided by niri-flake";
          wantedBy = [ "niri.service" ];
          after = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
          };
        };

        security.pam.services.swaylock = { };
        programs.dconf.enable = lib.mkDefault true;
        fonts.enableDefaultPackages = lib.mkDefault true;

        xdg = {
          autostart.enable = lib.mkDefault true;
          menus.enable = lib.mkDefault true;
          mime.enable = lib.mkDefault true;
          icons.enable = lib.mkDefault true;
        };

        services.displayManager.sessionPackages = [ cfg.package ];
        hardware.graphics.enable = true;
      }
    ]))
  ];
}
