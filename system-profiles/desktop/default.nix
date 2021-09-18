{ flake, pkgs, lib, ... }:
{
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
    fontconfig = {
      defaultFonts = {
        monospace = [ "PragmataPro Mono" ];
        sansSerif = [ "PragmataPro Mono" ];
      };
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
          <match>
            <test name="family">
              <string>alacritty</string>
            </test>
            <edit name="family" mode="assign_replace">
              <string>Noto Color Emoji</string>
              <string>Noto Emoji</string>
              <string>PragmataPro Mono</string>
            </edit>
          </match>
        </fontconfig>
      '';
    };
  };

  programs.firejail.enable = true;

  programs.dconf.enable = true;
  environment.noXlibs = lib.mkForce false;
  environment.systemPackages = with pkgs; [
    gnome3.dconf-editor
  ];
}
