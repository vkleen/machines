{ lib, inputs, pkgs, ... }:
{
  users.users.vkleen.extraGroups = [
    "audio"
    "video"
    "input"
    "uinput"
  ];

  boot.kernelPatches = [
    {
      name = "uinput-config";
      patch = null;
      extraConfig = ''
        INPUT_MISC y
        INPUT_UINPUT m
      '';
    }
  ];

  security.wrappers.seatd-launch = {
    owner = "root";
    group = "root";
    setuid = true;
    source = "${pkgs.seatd}/bin/seatd-launch";
  };
  environment.systemPackages = [ pkgs.seatd ];

  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "corefonts"
  ];

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = lib.attrValues {
      inherit (pkgs)
        inconsolata
        terminus_font
        ubuntu_font_family
        lmodern
        dejavu_fonts
        source-code-pro
        source-sans-pro
        source-serif-pro
        source-han-serif
        corefonts
        noto-fonts
        noto-fonts-cjk
        noto-fonts-emoji
        fira-code
        emacs-all-the-icons-fonts
        material-icons
        pragmatapro
        libertine
        ;
    };
  };

  home-manager.users.vkleen = lib.mkMerge (lib.attrValues {
    inherit (inputs.self.nixosModules.home)
      foot
      sway
      ;
  });
}
