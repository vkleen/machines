{ ... }:

{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = false;
  };
  home.sessionVariables.DIRENV_LOG_FORMAT = "";
}
