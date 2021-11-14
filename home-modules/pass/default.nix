{ pkgs, config, ... }:
let
  pass-symlink = pkgs.runCommand "pass-symlink" {} ''
    mkdir -p $out/bin
    ln -s "${pkgs.gopass}"/bin/gopass $out/bin/pass
  '';

  pass-completion = pkgs.runCommand "_gopass" {} ''
    ${pkgs.gopass}/bin/gopass completion zsh > $out
  '';
in {
  home.packages = [
    pass-symlink
  ];
  programs.password-store = {
    enable = true;
    package = pkgs.gopass;
    settings = {
      PASSWORD_STORE_DIR = "${config.xdg.dataHome}/password-store";
    };
  };

  xdg.configFile."gopass/config.yml".source = (pkgs.formats.yaml {}).generate "config.yml" {
    autoclip = false;
    autoimport = true;
    cliptimeout = 45;
    exportkeys = true;
    nopager = false;
    notifications = true;
    parsing = true;
    safecontent = false;
    path = "${config.xdg.dataHome}/password-store";
    mounts = {
      android = "${config.xdg.dataHome}/gopass/stores/android";
    };
  };

  xdg.configFile."zsh/vendor-completions/_gopass".source = pass-completion;
}
