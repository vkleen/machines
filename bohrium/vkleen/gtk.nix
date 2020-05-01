{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    adapta-gtk-theme
    arc-icon-theme
    arc-theme
    gnome3.adwaita-icon-theme
    gtk-engine-murrine
    gtk_engines
    hicolor-icon-theme
    materia-theme
    nixos-icons
    numix-icon-theme
    numix-solarized-gtk-theme
    paper-gtk-theme
    paper-icon-theme
  ];

  gtk = {
    enable = true;
    theme = {
      package = pkgs.arc-theme;
      name = "Arc-Dark";
    };
    iconTheme = {
      package = pkgs.arc-icon-theme;
      name = "Arc";
    };
    font = {
      package = null;
      name = "PragmataPro 12";
    };
  };
}
