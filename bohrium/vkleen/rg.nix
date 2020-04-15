{pkgs, config, ...}:
{
  home.packages = [ pkgs.ripgrep ];
  home.sessionVariables = {
    "RIPGREP_CONFIG_PATH" = "${config.xdg.configHome}/ripgrep/rc";
  };
  xdg.configFile."ripgrep/rc".text = ''
    --type-add
    pdf:*.PDF

    --type-add
    zathuradoc:*.{pdf,PDF,ps,djvu}

    --smart-case
  '';
}
