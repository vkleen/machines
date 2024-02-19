{ config, nixosConfig, ... }:
{
  programs.nixvim.plugins.toggleterm = {
    enable = true;
    openMapping = "<C-'>";
    direction = "float";
    shell = nixosConfig.users.users.${config.home.username}.shell;
  };
}
