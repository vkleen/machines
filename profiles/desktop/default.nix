{ flake, pkgs, ... }:
{
  system.configuration-type = "desktop";

  imports = [
    ./sway ./audio ./bitlbee ./cups
  ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [
      vaapiIntel
      intel-media-driver
    ];
  };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      inconsolata terminus_font ubuntu_font_family lmodern dejavu_fonts
      source-code-pro source-sans-pro source-serif-pro
      source-han-serif-simplified-chinese source-han-serif-traditional-chinese
      source-han-sans-simplified-chinese source-han-sans-simplified-chinese
      corefonts
      noto-fonts noto-fonts-cjk
      noto-fonts-emoji
      fira-code
      emacs-all-the-icons-fonts material-icons
      pragmatapro
      libertine #xits-math
    ];
    fontconfig.defaultFonts = {
      monospace = [ "PragmataPro Mono Liga Regular" ];
      sansSerif = [ "PragmataPro Mono Liga Regular" ];
    };
  };

  programs.firejail.enable = true;

  programs.dconf.enable = true;
  environment.systemPackages = with pkgs; [
    gnome3.dconf-editor
  ];
}
