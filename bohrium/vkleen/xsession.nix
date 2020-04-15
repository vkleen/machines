{pkgs, ...}:
{
  xsession = {
    enable = true;
    windowManager.command = "${pkgs.i3}/bin/i3";
  };

  services.unclutter = {
    enable = true;
  };

  xsession.initExtra = let
    i3-locker = pkgs.writeScriptBin "i3-locker" ''
      #!${pkgs.runtimeShell}
      walls=( $HOME/wallpapers/i3/*.png )
      exec ${pkgs.i3lock}/bin/i3lock -n -i "''${walls[RANDOM%''${#walls[@]}]}" -c 000000
    '';
  in ''
    systemctl --user import-environment GTK_PATH
    ${pkgs.xorg.xset}/bin/xset s off
    ${pkgs.xss-lock}/bin/xss-lock -- ${i3-locker}/bin/i3-locker &
    ${pkgs.xorg.setxkbmap}/bin/setxkbmap -option 'ctrl:nocaps'
    ${pkgs.xcape}/bin/xcape -e 'Control_L=Escape'
  '';

  services.random-background = {
    enable = true;
    imageDirectory = "%h/wallpapers/i3/";
    interval = "1h";
  };
}
