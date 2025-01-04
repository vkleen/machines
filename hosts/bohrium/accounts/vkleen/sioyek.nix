{ pkgs, lib, ... }:
{
  programs.sioyek = {
    enable = true;
    config = {
      "should_launch_new_window" = "1";
    };
  };
}
