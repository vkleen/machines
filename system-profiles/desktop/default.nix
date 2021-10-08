{ flake, pkgs, lib, ... }:
let
  emojiData = builtins.fetchurl {
    url = "https://www.unicode.org/Public/UCD/latest/ucd/emoji/emoji-data.txt";
    sha256 = "sha256-tZeDYSQpi49/oHYnOAKEDPwycaJfXDl6CC4SCVS4LDw=";
  };

  awkScript = ''
    BEGIN { IFS = ";"; }
    !/^[[:space:]]*($|#)/ {
      if (split($1, range, "\\.\\.") < 2)
        range[2] = range[1];

      printf "{\"min\":%d,\"max\":%d}", strtonum("0x"range[1]), strtonum("0x"range[2]);
    }
  '';

  emojiRanges = builtins.filter ({min, max}: max > 256)
    (builtins.fromJSON (lib.fileContents (pkgs.runCommand "emoji-ranges" {} ''
      ${pkgs.gawk}/bin/awk '${awkScript}' < ${emojiData} | ${pkgs.jq}/bin/jq -c --slurp '.' > $out
    '')));

  makeRangeEntry = {min,max}: "<range><int>${builtins.toString min}</int><int>${builtins.toString max}</int></range>";
in {
  imports = [
    ./sway ./audio ./bitlbee ./cups ./remarkable-cups
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
          <alias>
            <family>alacritty</family>
            <prefer>
              <family>PragmataPro Mono</family>
              <family>Noto Color Emoji</family>
            </prefer>
          </alias>

          <match>
            <test name="family">
              <string>alacritty</string>
            </test>
            <edit name="family" mode="prepend_first">
              <string>Noto Color Emoji</string>
            </edit>
          </match>

          <match target="font">
            <test name="family" compare="eq">
              <string>Noto Color Emoji</string>
            </test>
            <edit name="charset" mode="delete_all">
            </edit>
            <edit name="charset" mode="assign">
              <plus>
                <charset>
                  ${lib.concatMapStrings makeRangeEntry emojiRanges}
                </charset>
              </plus>
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
