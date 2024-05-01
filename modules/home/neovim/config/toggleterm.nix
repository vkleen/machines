{ config, nixosConfig, ... }:
{
  programs.nixvim.plugins.toggleterm = {
    enable = true;
    direction = "float";
    shell = nixosConfig.users.users.${config.home.username}.shell;
    settings.open_mapping = "[[<C-'>]]";
  };
}
