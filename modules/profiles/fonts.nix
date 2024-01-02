{ pkgs, lib, ... }:
let
  fonts = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "Cousine"
        "FiraCode"
        "Iosevka"
        "RobotoMono"
        "SourceCodePro"
      ];
    })
    b612
    carlito
    corefonts
    dejavu_fonts
    fira
    fira-code
    fira-mono
    inconsolata
    inter
    inter-ui
    libertine
    noto-fonts
    noto-fonts-emoji
    noto-fonts-extra
    pragmatapro
    roboto
    roboto-mono
    source-code-pro
    source-sans-pro
    source-serif-pro
    twitter-color-emoji
  ];
in
{
  nixpkgs.allowedUnfree = [
    "corefonts"
  ];
  fonts = {
    packages = fonts;

    fontDir.enable = true;
    fontconfig.enable = true;
    enableGhostscriptFonts = true;

    fontconfig.defaultFonts = {
      sansSerif = [ "PragmataPro Mono Liga" ];
      serif = [ "PragmataPro Mono Liga" ];
      monospace = [ "PragmataPro Mono Liga" ];
      emoji = [ "Noto Color Emoji" ];
    };

    fontconfig.localConf = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        <alias binding="weak">
          <family>monospace</family>
          <prefer>
            <family>emoji</family>
          </prefer>
        </alias>
        <alias binding="weak">
          <family>sans-serif</family>
          <prefer>
            <family>emoji</family>
          </prefer>
        </alias>
        <alias binding="weak">
          <family>serif</family>
          <prefer>
            <family>emoji</family>
          </prefer>
        </alias>
      </fontconfig>
    '';
  };
}
