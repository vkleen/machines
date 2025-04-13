{ pkgs, inputs, config, ... }:
{
  imports = [ inputs.stylix.nixosModules.stylix ];
  config = {
    stylix = {
      enable = true;
      image = ./eclipse.jpg;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      polarity = "dark";

      cursor = {
        package = pkgs.vanilla-dmz;
        size = 16;
        name = "Vanilla-DMZ";
      };

      opacity.desktop = 0.8;

      fonts = {
        monospace = {
          package = pkgs.pragmatapro;
          name = "PragmataPro Mono";
        };
        emoji = {
          package = pkgs.noto-fonts-emoji;
          name = "Noto Color Emoji";
        };
        serif = config.stylix.fonts.monospace;
        sansSerif = config.stylix.fonts.monospace;

        sizes.applications = 12;
        sizes.desktop = 12;
        sizes.popups = 10;
        sizes.terminal = 12;
      };
    };
  };
}

