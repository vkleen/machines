{ config, ... }:
{
  programs.taskwarrior = {
    enable = true;
    dataLocation = "${config.home.homeDirectory}/.task";
  };
}
