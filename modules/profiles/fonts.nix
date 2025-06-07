{ pkgs, lib, ... }:
let
  fonts = with pkgs; [
    b612
    carlito
    corefonts
    dejavu_fonts
    fira
    fira-code
    fira-mono
    inconsolata
    inter
    libertine
    nerd-fonts.cousine
    nerd-fonts.fira-code
    nerd-fonts.roboto-mono
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-emoji
    noto-fonts-extra
    pragmasevka
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
      sansSerif = [ "Pragmasevka" ];
      serif = [ "Pragmasevka" ];
      monospace = [ "Pragmasevka" ];
      emoji = [ "Noto Color Emoji" ];
    };

    # fontconfig.localConf = ''
    #   <?xml version="1.0"?>
    #   <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
    #   <fontconfig>
    #     <alias binding="weak">
    #       <family>monospace</family>
    #       <prefer>
    #         <family>emoji</family>
    #       </prefer>
    #     </alias>
    #     <alias binding="weak">
    #       <family>sans-serif</family>
    #       <prefer>
    #         <family>emoji</family>
    #       </prefer>
    #     </alias>
    #     <alias binding="weak">
    #       <family>serif</family>
    #       <prefer>
    #         <family>emoji</family>
    #       </prefer>
    #     </alias>
    #   </fontconfig>
    # '';
  };
}
